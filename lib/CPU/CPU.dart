// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

class CPU {
  static const int screenWidth = 64;
  static const int screenHeight = 32;

  // The Chip-8 has 4 kilobytes of memory
  List<int> memory = List.filled(4096, 0);

  /*
     * The display is 64 pixels wide and 32 pixels tall. Each pixel can be on or off.
     * In other words, each pixel is a boolean value, or a bit.
     * */
  final List<List<bool>> _display =
      List.generate(screenHeight, (_) => List.filled(screenWidth, false));

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
  List<int> variableRegisters = List.filled(16, 0x000);

  // The Chip-8 has a HEX based keypad (Ox0-0xF) in which we store the current state of the key
  // Keypad       Keyboard
  // +-+-+-+-+    +-+-+-+-+
  // |1|2|3|C|    |1|2|3|4|
  // +-+-+-+-+    +-+-+-+-+
  // |4|5|6|D|    |Q|W|E|R|
  // +-+-+-+-+ => +-+-+-+-+
  // |7|8|9|E|    |A|S|D|F|
  // +-+-+-+-+    +-+-+-+-+
  // |A|0|B|F|    |Z|X|C|V|
  // +-+-+-+-+    +-+-+-+-+
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
  int NN = 0;
  int NNN = 0;

  // Loaded rom
  late XFile file;

  // Function Table
  late Map<int, Function> functionTable;
  late Map<int, Function> functionTable8;
  late Map<int, Function> functionTable0;
  late Map<int, Function> functionTableE;
  late Map<int, Function> functionTableF;
  late Map<int, Function> functionTableF5;

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
      memory[0x50 + i] = fontSet[i];
    }

    // Reset nibbles
    F = 0;
    X = 0;
    Y = 0;
    N = 0;
    NN = 0;

    // assign function tables
    functionTable = {
      0x0: () => functionTable0[N]!.call(),
      0x1: _0x1NNN,
      0x2: _0x2NNN,
      0x3: _0x3XNN,
      0x4: _0x4XNN,
      0x5: _0x5XY0,
      0x6: _0x6XNN,
      0x7: _0x7XNN,
      0x8: () => functionTable8[N]!.call(),
      0x9: _0x9XY0,
      0xA: _0xANNN,
      0xB: _0xBNNN,
      0xC: _0xCXNN,
      0xD: _0xDXYN,
      0xE: () => functionTableE[Y]!.call(),
      0xF: () => functionTableF[N]!.call(),
    };

    functionTable0 = {
      0xE: _0x00EE,
      0x0: _0x00E0,
    };

    functionTable8 = {
      0x0: _0x8XYO,
      0x1: _0x8XY1,
      0x2: _0x8XY2,
      0x3: _0x8XY3,
      0x4: _0x8XY4,
      0x5: _0x8XY5,
      0x6: _0x8XY6,
      0x7: _0x8XY7,
      0xE: _0x8XYE,
    };

    functionTableE = {
      0xA: _0xEXA1,
      0x9: _0xEX9E,
    };

    functionTableF = {
      0x7: _0xFX07,
      0xA: _0xFX0A,
      0x5: () => functionTableF5[Y]!.call(),
      0x8: _0xFX18,
      0xE: _0xFX1E,
      0x9: _0xFX29,
      0x3: _0xFX33,
    };

    functionTableF5 = {
      0x1: _0xFX15,
      0x5: _0xFX55,
      0x6: _0xFX65,
    };
  }

  Future<void> loadRom(XFile file, int size, Uint8List buffer) async {
    this.file = file;
    for (int i = 0; i < size; i++) {
      // load file contents starting at 0x200
      memory[0x200 + i] = buffer[i];
    }
  }

  void emulateCycle() {
    // CPU Cycle = Fetch-Decode-Execute and then update timers
    fetch();
    decode();
    executeUsingTable();
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

    // Extract NN
    NN = opcode & 0x00FF;

    // Extract NNN
    NNN = opcode & 0x0FFF;
  }

  void executeUsingTable() {
    // Same as normal execute but uses faster table
    try {
      functionTable[F]!.call();
    } catch (e) {
      debugPrint("Fallback to switch execute: $e");
      execute();
    }
  }

  void execute() {
    // Get first nibble by masking opcode using AND bitwise operation
    switch (F) {
      case 0x0:
        {
          switch (N) {
            case 0xE:
              {
                _0x00EE();
                break;
              }
            case 0x0:
              {
                _0x00E0();
                break;
              }
          }
          break;
        }
      case 0xD:
        {
          _0xDXYN();
          break;
        }
      case 0x1:
        {
          _0x1NNN();
          break;
        }
      case 0x2:
        {
          _0x2NNN();
          break;
        }
      case 0x3:
        {
          _0x3XNN();
          break;
        }
      case 0x4:
        {
          _0x4XNN();
          break;
        }
      case 0x5:
        {
          _0x5XY0();
          break;
        }
      case 0x6:
        {
          _0x6XNN();
          break;
        }
      case 0x7:
        {
          _0x7XNN();
          break;
        }
      case 0x8:
        {
          switch (N) {
            case 0x0:
              _0x8XYO();
              break;
            case 0x1:
              _0x8XY1();
              break;
            case 0x2:
              _0x8XY2();
              break;
            case 0x3:
              _0x8XY3();
              break;
            case 0x4:
              _0x8XY4();
              break;
            case 0x5:
              _0x8XY5();
              break;
            case 0x6:
              _0x8XY6();
              break;
            case 0x7:
              _0x8XY7();
              break;
            case 0xE:
              _0x8XYE();
              break;
          }
          break;
        }
      case 0x9:
        {
          _0x9XY0();
          break;
        }
      case 0xA:
        {
          _0xANNN();
          break;
        }
      case 0xB:
        {
          _0xBNNN();
          break;
        }
      case 0xC:
        {
          _0xCXNN();
          break;
        }
      case 0xE:
        {
          switch (Y) {
            case 0xA:
              {
                _0xEXA1();
                break;
              }
            case 0x9:
              {
                _0xEX9E();
                break;
              }
          }
          break;
        }
      case 0xF:
        switch (N) {
          case 0x7:
            {
              _0xFX07();
              break;
            }
          case 0xA:
            {
              _0xFX0A();
              break;
            }
          case 0x5:
            {
              switch (Y) {
                case 0x1:
                  {
                    _0xFX15();
                    break;
                  }
                case 0x5:
                  {
                    _0xFX55();
                    break;
                  }
                case 0x6:
                  {
                    _0xFX65();
                    break;
                  }
              }
              break;
            }
          case 0x8:
            {
              _0xFX18();
              break;
            }
          case 0xE:
            {
              _0xFX1E();
              break;
            }
          case 0x9:
            {
              _0xFX29();
              break;
            }
          case 0x3:
            {
              _0xFX33();
              break;
            }
        }
        break;
      default:
        if (kDebugMode) {
          print("Error: Unknown Opcode $opcode");
        }
    }
  }

  void updateDelayTimer() {
    // Remember that delay timer counts down until 0 at 60 Hz
    if (delayTimer > 0) {
      if (delayTimer == 1) {
        if (kDebugMode) {
          print("Delay Timer Activated!");
        }
      }
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
    for (int r = 0; r < screenHeight; r++) {
      for (int c = 0; c < screenWidth; c++) {
        _display[r][c] = false;
      }
    }
  }

  // Handles returning from a subroutine
  void _0x00EE() {
    stackPointer--;
    programCounter = stack[stackPointer];
  }

  // Handles clearing the display
  void _0x00E0() {
    clearDisplay();
  }

  // Handles jump to location NNN
  void _0x1NNN() {
    // computer location NNN and set program counter
    programCounter = NNN;
  }

  // Handles skip next instruction if Vopx = NN
  void _0x3XNN() {
    // if v_x = NN, then skip next instruction
    if (variableRegisters[X] == NN) {
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

  // Handles skip next instruction if Vx != NN
  void _0x4XNN() {
    // if Vx != NN, then skip next instruction
    if (variableRegisters[X] != NN) {
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

  // Handles setting Vx == NN
  void _0x6XNN() {
    variableRegisters[X] = NN;
  }

  // Handles setting Vx to itself + NN
  void _0x7XNN() {
    variableRegisters[X] += NN;
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
      variableRegisters[0xF] = 1;
    } else {
      variableRegisters[0xF] = 0;
    }
    variableRegisters[X] = (variableRegisters[X] + variableRegisters[Y]) & 0xFF;
  }

  // Handles setting Vx = Vx - Vy, setting VF = not borrow.
  void _0x8XY5() {
    // if Vx > Vy set Vf to 1 else 0
    if (variableRegisters[X] > variableRegisters[Y]) {
      variableRegisters[0xF] = 1;
    } else {
      variableRegisters[0xF] = 0;
    }
    variableRegisters[X] -= variableRegisters[Y];
  }

  // Handles setting Vx = Vx SHR 1
  void _0x8XY6() {
    // if the least-significant bit of Vx is 1, then VF is set to 1, else 0.
    variableRegisters[0xF] = variableRegisters[X] & 0x1;
    // Vx is divided by 2
    variableRegisters[X] >>= 1;
  }

  // Handles setting Vx = Vy - Vx, setting VF = not borrow
  void _0x8XY7() {
    // if Vy > Vx set VF to 1 else 0
    if (variableRegisters[Y] > variableRegisters[X]) {
      variableRegisters[0xF] = 1;
    } else {
      variableRegisters[0xF] = 0;
    }
    variableRegisters[X] = variableRegisters[Y] - variableRegisters[X];
  }

  // Handles setting Vx = Vx SHL 1
  void _0x8XYE() {
    // if the most-significant bit of Vx is 1, then VF is set to 1, else 0
    variableRegisters[0xF] = (variableRegisters[X] & 0x80) >> 7;
    // Vx is multiplied by 2
    variableRegisters[X] <<= 1;
  }

  // Handles skipping next instruction if Vx != Vy.
  void _0x9XY0() {
    if (variableRegisters[X] != variableRegisters[Y]) {
      programCounter += 2;
    }
  }

  // Handles setting index = NNN
  void _0xANNN() {
    indexRegister = NNN;
  }

  // Handles jump to location NNN + V0.
  void _0xBNNN() {
    programCounter = NNN + variableRegisters[0];
  }

  // Handles setting Vx = random byte AND NN.
  void _0xCXNN() {
    variableRegisters[X] = -128 + Random().nextInt(256) + NN;
  }

  // Handles skipping next instruction if key with the value of Vx is not pressed.
  void _0xEXA1() {
    // if key Vx is not pressed, skip next instruction
    if (key[variableRegisters[X]] == 0) {
      programCounter += 2;
    }
  }

  // Handles skipping next instruction if key with the value of Vx is pressed.
  void _0xEX9E() {
    // if key Vx is pressed, skip next instruction
    if (key[variableRegisters[X]] == 1) {
      programCounter += 2;
    }
  }

  // Handles setting Vx to delay timer value
  void _0xFX07() {
    variableRegisters[X] = delayTimer;
  }

  // Handles waiting for a key press and storing value in Vx
  void _0xFX0A() {
    bool hasKey = false;
    for (int i = 0; i < 16 && !hasKey; i++) {
      if (key[i] == 1) {
        variableRegisters[X] = key[i];
        hasKey = true;
      }
    }
    // if no key found go back to this instruction again and try again
    if (!hasKey) {
      programCounter -= 2;
    }
  }

  // Handles setting delay timer = Vx
  void _0xFX15() {
    delayTimer = variableRegisters[X];
  }

  // Handles setting sound timer = Vx
  void _0xFX18() {
    soundTimer = variableRegisters[X];
  }

  // Set index = index + Vx
  void _0xFX1E() {
    indexRegister += variableRegisters[X];
  }

  // Handles setting index to location of Vx sprite
  void _0xFX29() {
    // font chars start at 0x50, and each one is 5 bytes, so use offset
    // to get address of of the first byte of the character
    indexRegister = 0x50 + (5 * variableRegisters[X]);
  }

  // Handles storing V0 to Vx in memory starting at index
  void _0xFX55() {
    for (int i = 0; i < X; i++) {
      memory[indexRegister + i] = variableRegisters[i];
    }
  }

  // Handles storing Vx BCD representation in mem location index, index + 1, index + 2
  void _0xFX33() {
    int Vx = variableRegisters[X];

    // first digit (ones place)
    memory[indexRegister + 2] = Vx % 10;
    Vx ~/= 10;

    // second digit (tens place)
    memory[indexRegister + 1] = Vx % 10;
    Vx ~/= 10;

    // third digit (hundreds place)
    memory[indexRegister] = Vx % 10;
  }

  // Handles reading V0 to Vx from memory locations starting at index
  void _0xFX65() {
    for (int i = 0; i < X; i++) {
      variableRegisters[i] = memory[indexRegister + i];
    }
  }

  // Handles drawing to the display
  void _0xDXYN() {
    // Get the X and Y coordinates from VX and VY (cannot use X and Y)
    int x = variableRegisters[(opcode & 0x0F00) >> 8] % screenWidth;
    int y = variableRegisters[(opcode & 0x00F0) >> 4] % screenHeight;
    int length = opcode & 0xF;

    // Set VF to zero
    variableRegisters[0xF] = 0;

    //Initialize bit value
    int bit;

    // Loop through n number of rows
    for (int row = 0; row < length; row++) {
      // Get the Nth byte of sprite data, counting from the memory address in the index register
      bit = memory[indexRegister + row];

      // Loop through each of the 8 bits in this sprite row
      for (int col = 0; col < 8; col++) {
        /* If the current pixel is on and the pixel at coordinates X,Y
                on the screen is also on turn off the pixel and set VF to 1 */
        if ((bit & (0x80 >> col)) != 0) {
          int element = x + col + ((y + row) * screenWidth);

          if (_display[(element ~/ screenWidth) % screenHeight]
              [element % screenWidth]) {
            variableRegisters[0xF] = 1;
          }
          _display[(element ~/ screenWidth) % screenHeight]
                  [element % screenWidth] =
              _display[(element ~/ screenWidth) % screenHeight]
                  [element % screenWidth] ^= true;
        }
      }
    }
  }

  Map<int, int> getMemoryDebugMap() {
    Map<int, int> memMap = {};
    for (int i = 0; i < memory.length; i++) {
      if (memory[i] != 0) {
        memMap[i] = memory[i];
      }
    }
    return memMap;
  }
}
