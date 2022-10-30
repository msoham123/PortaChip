import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

class StateNotifier extends ChangeNotifier {
  // Class for updating app state
  bool isDarkMode = false;
  late var deviceInfo;

  void updateTheme(bool isDarkMode) {
    this.isDarkMode = isDarkMode;
    notifyListeners();
  }

  Future<void> loadAppInfo() async {
    DeviceInfoPlugin info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      deviceInfo = await deviceInfo as AndroidDeviceInfo;
    } else if (Platform.isIOS) {
      deviceInfo = await deviceInfo.iosInfo as IosDeviceInfo;
    } else if (Platform.isMacOS) {
      deviceInfo = await deviceInfo.macOsInfo as MacOsDeviceInfo;
    } else if (Platform.isLinux) {
      deviceInfo = await deviceInfo.linuxInfo as LinuxDeviceInfo;
    } else if (Platform.isWindows) {
      deviceInfo = await deviceInfo.windowsInfo as WindowsDeviceInfo;
    } else {
      deviceInfo = await deviceInfo.webBrowserInfo as WebBrowserInfo;
    }
    info = info;
  }
}
