import 'package:flutter/material.dart';
import 'package:portachip/Services/StateNotifier.dart';
import 'package:portachip/UI/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'package:portachip/UI/AppTheme.dart';

void main() {
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
