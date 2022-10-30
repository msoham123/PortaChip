import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

class StateNotifier extends ChangeNotifier {
  // Class for updating app state
  bool isDarkMode = false;
  late String devicePlatform;
  late String deviceHardware;

  void updateTheme(bool isDarkMode) {
    this.isDarkMode = isDarkMode;
    notifyListeners();
  }

  Future<void> loadAppInfo() async {
    DeviceInfoPlugin info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo deviceInfo = await info.deviceInfo as AndroidDeviceInfo;
      devicePlatform = deviceInfo.model;
      deviceHardware = deviceInfo.hardware;
    } else if (Platform.isIOS) {
      IosDeviceInfo deviceInfo = await info.deviceInfo as IosDeviceInfo;
      devicePlatform = deviceInfo.name ?? "Device Platform";
      deviceHardware = deviceInfo.model ?? "Device Hardware";
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo deviceInfo = await info.deviceInfo as MacOsDeviceInfo;
      devicePlatform = deviceInfo.model;
      deviceHardware =
          "Mac OS (${deviceInfo.arch}) ${deviceInfo.activeCPUs} cores at ${deviceInfo.cpuFrequency}";
    } else if (Platform.isLinux) {
      LinuxDeviceInfo deviceInfo = await info.deviceInfo as LinuxDeviceInfo;
      devicePlatform = deviceInfo.prettyName;
      deviceHardware = deviceInfo.machineId ?? "Device Hardware";
    } else if (Platform.isWindows) {
      WindowsDeviceInfo deviceInfo = await info.deviceInfo as WindowsDeviceInfo;
      devicePlatform = deviceInfo.deviceId;
      deviceHardware = "Windows ${deviceInfo.numberOfCores}";
    } else {
      WebBrowserInfo deviceInfo = await info.deviceInfo as WebBrowserInfo;
      devicePlatform = deviceInfo.platform ?? "Device Platform";
      deviceHardware =
          "${deviceInfo.platform} ${deviceInfo.browserName.name} ${deviceInfo.deviceMemory}";
    }
  }
}
