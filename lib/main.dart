import 'package:flutter/material.dart';

import 'CPU/CPU.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CPU cpu = CPU();

  @override
  void initState() {
    cpu.initialize();
    super.initState();
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
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: CustomPaint(
            painter: Display(cpu),
            size: MediaQuery.of(context).size,
          ),
        ));
  }
}

class Display extends CustomPainter {
  CPU cpu;
  final painter = Paint()
    ..strokeWidth = 5
    ..color = Colors.indigoAccent
    ..style = PaintingStyle.stroke;

  Display(this.cpu);

  @override
  void paint(Canvas canvas, Size size) {
    double recWidth = size.width / 63;
    double recHeight = size.height / 31;

    for (int r = 0; r < 32; r++) {
      for (int c = 0; c < 64; c++) {
        if (cpu.getDisplayState(r, c) == false) {
          canvas.drawRect(
              Rect.fromLTRB(c * recWidth, r * recHeight, recWidth, recHeight),
              painter);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
