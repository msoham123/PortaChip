import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class StateNotifier extends ChangeNotifier {
  // Class for updating app state
  bool isDarkMode = false;
  String deviceData = "";
  int upscale = 1;
  bool isPaused = false;
  bool showFPS = false;
  int refreshDelay = 16667; //microseconds = 16.67 ms = 1/60 sec
  late File settingsFile;
  late Map<String, dynamic> settings;

  void updateTheme(bool isDarkMode) {
    this.isDarkMode = isDarkMode;
    notifyListeners();
  }

  Future<void> loadAppInfo() async {
    if (!kIsWeb && Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      var directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      settingsFile = File("$path/settings.txt");
      bool exists = await settingsFile.exists();
      if (!exists) {
        Map<String, dynamic> settingsMap = {
          "darkMode": false,
        };
        await settingsFile.writeAsString(json.encode(settingsMap));
      }
      String contents = await settingsFile.readAsString();
      debugPrint("Loaded settings file at $path/settings.txt\n$contents");
      settings = json.decode(contents);
      isDarkMode = settings["darkMode"] as bool;
    }

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

  Future<void> updateSettings(String key, var value) async {
    settings[key] = value;
    await settingsFile.writeAsString(json.encode(settings));
  }
}
