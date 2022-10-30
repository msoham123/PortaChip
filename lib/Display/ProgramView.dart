import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:portachip/UI/Footer.dart';
import '../CPU/CPU.dart';
import 'Display.dart';

class ProgramView extends StatefulWidget {
  const ProgramView({super.key});

  @override
  State<ProgramView> createState() => _ProgramViewState();
}

class _ProgramViewState extends State<ProgramView>
    with SingleTickerProviderStateMixin {
  late CPU cpu = CPU();
  late AnimationController _controller;
  bool _showDebugInfo = false;
  bool _romLoaded = false;

  @override
  void initState() {
    cpu.initialize();
    chooseRom();
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

  Future<void> chooseRom() async {
    const XTypeGroup typeGroup =
        XTypeGroup(label: "images", extensions: ["ch8"]);
    XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      // get size of file
      int size = await file.length();
      // read contents of file as bytes
      Uint8List buffer = await file.readAsBytes();
      cpu.loadRom(file, size, buffer);
      setState(() {
        _romLoaded = true;
      });
    } else {
      chooseRom();
    }
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
        backgroundColor: Colors.black54,
        // floatingActionButton: SizedBox(
        //   width: 150,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       FloatingActionButton(
        //         child: const Icon(Icons.bug_report),
        //         onPressed: () {
        //           setState(() {
        //             _showDebugInfo = !_showDebugInfo;
        //           });
        //         },
        //       ),
        //       FloatingActionButton(
        //         child: const Icon(Icons.forward),
        //         onPressed: () {
        //           try {
        //             cpu.emulateCycle();
        //           } catch (e, s) {
        //             if (kDebugMode) print("$e ::: $s");
        //           }
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        body: Column(
          children: [
            Expanded(child: SizedBox()),
            Center(
              child: AspectRatio(
                aspectRatio: 2 / 1,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) {
                    if (!_showDebugInfo && _romLoaded) {
                      cpu.emulateCycle();
                      return CustomPaint(
                          willChange: true,
                          painter: Display(cpu: cpu, listenable: _controller),
                          size: MediaQuery.of(context).size);
                    } else if (_romLoaded) {
                      cpu.emulateCycle();
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text("PC: ${cpu.programCounter}"),
                              Text("index: ${cpu.indexRegister}"),
                              Text("SP: ${cpu.stackPointer}"),
                              Text("DT: ${cpu.delayTimer}"),
                              Text("ST: ${cpu.soundTimer}"),
                              Text("op: ${cpu.opcode}"),
                              Text("F: ${cpu.F}"),
                              Text("X: ${cpu.X}"),
                              Text("Y: ${cpu.Y}"),
                              Text("N: ${cpu.N}"),
                              Text("NN: ${cpu.NN}"),
                              Text("NNN: ${cpu.NNN}"),
                              Text(
                                  "Memory (loc, val): ${cpu.getMemoryDebugMap().toString().replaceAll(",", "   |   ")}"),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            Footer(),
          ],
        ));
  }
}
