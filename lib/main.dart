import 'package:flutter/material.dart';
import 'package:portachip/Display/ProgramView.dart';
import 'package:portachip/Services/StateNotifier.dart';
import 'package:provider/provider.dart';

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
    return MaterialApp(
        showPerformanceOverlay: false,
        title: 'PortaChip',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ProgramView());
  }
}
