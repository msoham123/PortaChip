import 'package:portachip/CPU/CPU.dart';
import 'package:flutter/material.dart';

abstract class KeyState {
  static Map<String, int> _keyMap = {
    "1": 0,
    "2": 1,
    "3": 2,
    "4": 3,
    "Q": 4,
    "W": 5,
    "E": 6,
    "R": 7,
    "A": 8,
    "S": 9,
    "D": 10,
    "F": 11,
    "Z": 12,
    "X": 13,
    "C": 14,
    "V": 15,
  };

  static handleKeyInput(RawKeyEvent event, CPU cpu) {
    if (event.character != null && _keyMap.containsKey(event.character)) {
      if (event.runtimeType.toString() == "RawKeyDownEvent") {
        cpu.key[_keyMap[event.character]!] = 1;
      } else {
        cpu.key[_keyMap[event.character]!] = 0;
      }
    }
  }
}
