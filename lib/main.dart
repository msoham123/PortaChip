import 'package:flutter/material.dart';
import 'package:statsfl/statsfl.dart';
import 'CPU/CPU.dart';

void main() {
  runApp(StatsFl(
    isEnabled: true,
    align: Alignment.topLeft,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        showPerformanceOverlay: false,
        title: 'PortaChip',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late CPU cpu = CPU();
  late AnimationController _controller;

  @override
  void initState() {
    cpu.initialize();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            cpu.invertDisplayState(20, 20);
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              // cpu.emulateCycle();
              return CustomPaint(
                  willChange: true,
                  painter: Display(cpu: cpu, listenable: _controller),
                  size: MediaQuery.of(context).size);
            },
          ),
        ));
  }
}

class Display extends CustomPainter {
  final Animation listenable;
  CPU cpu;
  var painter = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  Display({required this.cpu, required this.listenable})
      : super(repaint: listenable);

  @override
  void paint(Canvas canvas, Size size) {
    double recWidth = size.width / 64;
    double recHeight = size.height / 32;

    for (int r = 0; r < 32; r++) {
      for (int c = 0; c < 64; c++) {
        if (cpu.getDisplayState(r, c) == false) {
          canvas.drawRect(
              Rect.fromLTWH(c * recWidth, r * recHeight, recWidth, recHeight),
              painter);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => this != oldDelegate;
}
