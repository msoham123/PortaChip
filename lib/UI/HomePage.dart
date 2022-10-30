import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portachip/UI/TileButton.dart';
import '../CPU/CPU.dart';
import '../Display/ProgramView.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CPU cpu = CPU();
  bool _romLoaded = false;

  @override
  void initState() {
    cpu.initialize();
    super.initState();
  }

  @override
  void dispose() {
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
      setState(() {
        _romLoaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TileButton(
                onTap: () async {
                  await chooseRom();
                  if (_romLoaded) {
                    Future.delayed(Duration.zero, () {
                      Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: ProgramView(cpu: cpu)),
                      );
                    });
                  }
                },
                text: "Load ROM",
                icon: Icons.open_in_browser_rounded,
              ),
            ],
          ),
        ));
  }
}
