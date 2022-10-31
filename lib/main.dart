import 'package:flutter/material.dart';
import 'package:portachip/Services/StateNotifier.dart';
import 'package:portachip/UI/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'package:portachip/UI/AppTheme.dart';
import 'package:desktop_window/desktop_window.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await DesktopWindow.setWindowSize(Size(1355, 750));
    await DesktopWindow.setMinWindowSize(Size(750, 750));
    await DesktopWindow.setMaxWindowSize(Size.infinite);
    // await DesktopWindow.resetMaxWindowSize();
    // await DesktopWindow.toggleFullScreen();
    // bool isFullScreen = await DesktopWindow.getFullScreen();
    // await DesktopWindow.setFullScreen(true);
    // await DesktopWindow.setFullScreen(false);
  }
  runApp(
    ChangeNotifierProvider<StateNotifier>(
      create: (context) => StateNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StateNotifier>(
      builder: (context, appState, child) {
        return MaterialApp(
          showPerformanceOverlay: false,
          title: 'PortaChip',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          debugShowCheckedModeBanner: false,
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashView(),
        );
      },
    );
  }
}
