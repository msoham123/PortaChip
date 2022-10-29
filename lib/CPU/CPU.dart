// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';

class CPU {
  // The Chip-8 has 4 kilobytes of memory
  List<int> memory = List.filled(4096, 0);

  /*
     * The display is 64 pixels wide and 32 pixels tall. Each pixel can be on or off.
     * In other words, each pixel is a boolean value, or a bit.
     * */
  final List<List<bool>> _display =
      List.generate(32, (_) => List.filled(64, false));

  // A program counter which points at the current instruction in memory
  int programCounter = 0;

  // One 16-bit index register which is used to point at locations in memory
  int indexRegister = 0;

  // A stack for 16-bit addresses, which is used to call subroutines/functions and return from them
  List<int> stack = List.filled(16, 0);

  // A stack pointer points to the level of the stack which is being used
  int stackPointer = 0;

  // An 8-bit delay timer which is decremented at a rate of 60 Hz (60 times per second) until it reaches 0
  int delayTimer = 0;

  // An 8-bit sound timer which functions like the delay timer, but which also gives off a beeping sound as long as it’s not 0
  int soundTimer = 0;

  // The Chip-8 has 35 opcodes, or 35 operations, each two bytes (16 bits) long
  int opcode = 0;

  /*
  * The Chip-8 has 16 8-bit (one byte) general-purpose variable registers numbered
  * 0 through F hexadecimal (0 through 15 in decimal) called V0 through VF
  * */
  List<int> variableRegisters = List.filled(16, 0);

  // The Chip-8 has a HEX based keypad (Ox0-0xF) in which we store the current state of the key
  List<int> key = List.filled(16, 0);

  // Of every value, we use the binary representation to draw using first four bits (nibble) a number or character.
  List<int> fontSet = [
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80 // F
  ];

  // All four nibbles decoded from the opcode (let F be the first nibble)
  int F = 0;
  int X = 0;
  int Y = 0;
  int N = 0;

  // Other needed bytes
  int KK = 0;

  void initialize() {
    // Clear memory
    for (int i = 0; i < 4096; i++) {
      memory[i] = 0;
    }

    // Reset display
    clearDisplay();

    // Reset program counter (starts at 0x200)
    programCounter = 0x200;

    // Reset index register
    indexRegister = 0;

    // Reset stack, variable registers, and keypad
    for (int i = 0; i < 16; i++) {
      stack[i] = 0;
      variableRegisters[i] = 0;
      key[i] = 0;
    }

    // Reset stack pointer
    stackPointer = 0;

    // Reset timers
    delayTimer = 0;
    soundTimer = 0;

    // Reset opcode
    opcode = 0;

    // Load font set into memory starting at 0x50 to 0x09F
    for (int i = 0; i < 80; i++) {
      memory[i] = fontSet[i];
    }

    // Reset nibbles
    F = 0;
    X = 0;
    Y = 0;
    N = 0;
    KK = 0;
  }

  void emulateCycle() {
    // CPU Cycle = Fetch-Decode-Execute and then update timers
    fetch();
    decode();
    execute();
    updateDelayTimer();
    updateSoundTimer();
  }

  void fetch() {
    // Remember that opcodes are 16 bit types
    // Fetch 8-bit address, shift it by 8, and merge using OR bitwise operation
    opcode = memory[programCounter] << 8 | memory[programCounter + 1];

    // Increment program counter by 2 to be ready to fetch next opcode
    programCounter += 2;
  }

  void decode() {
    // Extract nibble F
    F = (opcode & 0xF000) >> 12;
    // Extract nibble X
    X = (opcode & 0x0F00) >> 8;
    // Extract nibble Y
    Y = (opcode & 0x00F0) >> 4;
    // Extract nibble Z
    N = opcode & 0x000F;

    // Extract KK
    KK = opcode & 0x00FF;
  }

  void execute() {
    // Get first nibble by masking opcode using AND bitwise operation
    if (F == 0xD000) {
      _0xDXYN();
    } else if (F == 0x2000) {
      _0x2NNN();
    } else if (F == 0x1000) {
      _0x1NNN();
    } else if (F == 0x3000) {
      _0x3XKK();
    } else if (F == 0x4000) {
      _0x4XKK();
    } else if (F == 0x5000) {
      _0x5XY0();
    } else if (F == 0x6000) {
      _0x6XKK();
    } else if (F == 0x7000) {
      _0x7XKK();
    } else if (F == 0x8000) {
      if (N == 0x0000) {
        _0x8XYO();
      } else if (N == 0x0001) {
        _0x8XY1();
      } else if (N == 0x0002) {
        _0x8XY2();
      } else if (N == 0x0003) {
        _0x8XY3();
      } else if (N == 0x0004) {
        _0x8XY4();
      } else if (N == 0x0005) {
        _0x8XY5();
      } else if (N == 0x0006) {
        _0x8XY6();
      } else if (N == 0x0007) {
        _0x8XY7();
      } else {
        _0x8XYE();
      }
    } else if (F == 0x9000) {
      _0x9XY0();
    } else {
      if (kDebugMode) {
        print("Error: Unknown Opcode $opcode");
      }
    }
  }

  void updateDelayTimer() {
    // Remember that delay timer counts down until 0 at 60 Hz
    if (delayTimer > 0) {
      delayTimer--;
    }
  }

  void updateSoundTimer() {
    // Remember that sound timer counts down until 0 at 60 Hz
    if (soundTimer > 0) {
      if (soundTimer == 1) {
        if (kDebugMode) {
          print("Sound Timer Activated!");
        }
      }
      soundTimer--;
    }
  }

  bool getDisplayState(int row, int col) {
    return _display[row][col];
  }

  void updateDisplayState(int row, int col, bool state) {
    _display[row][col] = state;
  }

  void invertDisplayState(int row, int col) {
    _display[row][col] = !_display[row][col];
  }

  void loadGame() {
    /*
    FILE* gameFile;
    gameFile = fopen(gameName, "rb");
    if (gameFile != NULL) {
        for (int i = 0; i < 0; i++)
        {
        }
    }
   */
  }

  void clearDisplay() {
    for (int r = 0; r < 32; r++) {
      for (int c = 0; c < 64; c++) {
        _display[r][c] = false;
      }
    }
  }

  // Handles jump to location NNN
  void _0x1NNN() {
    // computer location NNN and set program counter
    programCounter = opcode & 0x0FFF;
  }

  // Handles skip next instruction if V_x = KK
  void _0x3XKK() {
    // if v_x = KK, then skip next instruction
    if (variableRegisters[X] == KK) {
      programCounter += 2;
    }
  }

  // Handles returning of subroutines
  void _0x2NNN() {
    // set the current position of the stack to program counter
    stack[stackPointer] = programCounter;
    // increment stack pointer
    stackPointer++;
    // jump
    _0x1NNN();
  }

  // Handles skip next instruction if Vx != KK
  void _0x4XKK() {
    // if Vx != KK, then skip next instruction
    if (variableRegisters[X] != KK) {
      programCounter += 2;
    }
  }

  // Handles skip next instruction if Vx = Vy
  void _0x5XY0() {
    // if Vx = Vy, then skip next instruction
    if (variableRegisters[X] == variableRegisters[Y]) {
      programCounter += 2;
    }
  }

  // Handles setting Vx == kk
  void _0x6XKK() {
    variableRegisters[X] = KK;
  }

  // Handles setting Vx to itself + kk
  void _0x7XKK() {
    variableRegisters[X] += KK;
  }

  // Handles setting Vx = Vy
  void _0x8XYO() {
    variableRegisters[X] = variableRegisters[Y];
  }

  // Handles setting Vx = Vx or Vy
  void _0x8XY1() {
    variableRegisters[X] |= variableRegisters[Y];
  }

  // Handles setting Vx = Vx and Vy
  void _0x8XY2() {
    variableRegisters[X] &= variableRegisters[Y];
  }

  // Handles setting Vx = Vx xor Vy
  void _0x8XY3() {
    variableRegisters[X] ^= variableRegisters[Y];
  }

  // Handles setting Vx = Vx + Vy, setting VF = carry.
  void _0x8XY4() {
    // if sum is greater than what can fit into a byte, overflow flag is set
    if (variableRegisters[X] + variableRegisters[Y] > 255) {
      variableRegisters[F] = 1;
    } else {
      variableRegisters[F] = 0;
    }
    variableRegisters[X] = (variableRegisters[X] + variableRegisters[Y]) & 0xFF;
  }

  // Handles setting Vx = Vx - Vy, setting VF = not borrow.
  void _0x8XY5() {
    // if Vx > Vy set Vf to 1 else 0
    if (variableRegisters[X] > variableRegisters[Y]) {
      variableRegisters[F] = 1;
    } else {
      variableRegisters[F] = 0;
    }
    variableRegisters[X] -= variableRegisters[Y];
  }

  // Handles setting Vx = Vx SHR 1
  void _0x8XY6() {
    // if the least-significant bit of Vx is 1, then VF is set to 1, else 0.
    variableRegisters[F] = variableRegisters[X] & 0x1;
    // Vx is divided by 2
    variableRegisters[X] >>= 1;
  }

  // Handles setting Vx = Vy - Vx, setting VF = not borrow
  void _0x8XY7() {
    // if Vy > Vx set VF to 1 else 0
    if (variableRegisters[Y] > variableRegisters[X]) {
      variableRegisters[F] = 1;
    } else {
      variableRegisters[F] = 0;
    }
    variableRegisters[X] = variableRegisters[Y] - variableRegisters[X];
  }

  // Handles setting Vx = Vx SHL 1
  void _0x8XYE() {
    // if the most-significant bit of Vx is 1, then VF is set to 1, else 0
    variableRegisters[F] = (variableRegisters[X] & 0x80) >> 7;
    // Vx is multiplied by 2
    variableRegisters[X] <<= 1;
  }

  // Handles skipping next instruction if Vx != Vy.
  void _0x9XY0() {
    if (variableRegisters[X] != variableRegisters[Y]) {
      programCounter += 2;
    }
  }

  // Handles drawing to the display
  void _0xDXYN() {
    // Get the X and Y coordinates from VX and VY
    int x = variableRegisters[X >> 8];
    int y = variableRegisters[Y >> 4];

    // Set VF to zero
    variableRegisters[0xF] = 0;

    //Initialize bit value
    int bit;

    // Loop through n number of rows
    for (int n = 0; n < N; n++) {
      // Get the Nth byte of sprite data, counting from the memory address in the index register
      bit = memory[indexRegister + n];

      // Loop through each of the 8 bits in this sprite row
      for (int i = 0; i < 8; i++) {
        /* If the current pixel is on and the pixel at coordinates X,Y
                on the screen is also on turn off the pixel and set VF to 1 */
        if ((bit & (0x80 >> i)) != 0) {
          if (_display[x + i][y + n]) {
            variableRegisters[0xF] = 1;
          }
          _display[x + i][y + n] = !_display[x + i][y + n];
        }
      }
    }
  }
}
