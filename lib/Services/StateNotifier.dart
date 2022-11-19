import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class StateNotifier extends ChangeNotifier {
  // Class for updating app state
  bool isDarkMode = false;
  String deviceData = "";
  int upscale = 1;
  bool isPaused = false;
  bool showFPS = false;
  int refreshDelay = 16667; //microseconds = 16.67 ms = 1/60 sec

  void updateTheme(bool isDarkMode) {
    this.isDarkMode = isDarkMode;
    notifyListeners();
  }

  Future<void> loadAppInfo() async {
    DeviceInfoPlugin info = DeviceInfoPlugin();
    if (kIsWeb) {
      WebBrowserInfo deviceInfo = await info.deviceInfo as WebBrowserInfo;
      deviceData =
          "${deviceInfo.platform ?? "Device Platform"}${deviceInfo.platform} ${deviceInfo.browserName.name} ${deviceInfo.deviceMemory}";
    } else if (Platform.isIOS) {
      IosDeviceInfo deviceInfo = await info.deviceInfo as IosDeviceInfo;
      deviceData = (deviceInfo.name ?? "Device Platform") +
          (deviceInfo.model ?? "Device Hardware");
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo deviceInfo = await info.deviceInfo as MacOsDeviceInfo;
      deviceData =
          "Mac OS ${deviceInfo.osRelease} | ${deviceInfo.hostName} ${deviceInfo.arch} | ${deviceInfo.activeCPUs} cores";
    } else if (Platform.isLinux) {
      LinuxDeviceInfo deviceInfo = await info.deviceInfo as LinuxDeviceInfo;
      deviceData =
          deviceInfo.prettyName + (deviceInfo.machineId ?? "Device Hardware");
    } else if (Platform.isWindows) {
      WindowsDeviceInfo deviceInfo = await info.deviceInfo as WindowsDeviceInfo;
      deviceData = "${deviceInfo.deviceId} Windows ${deviceInfo.numberOfCores}";
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo deviceInfo = await info.deviceInfo as AndroidDeviceInfo;
      deviceData = deviceInfo.model + deviceInfo.hardware;
    } else {
      deviceData = "Platform not found";
    }
  }
}
