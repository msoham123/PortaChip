import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:portachip/Services/StateNotifier.dart';
import 'package:portachip/UI/Footer.dart';
import 'package:provider/provider.dart';
import 'package:statsfl/statsfl.dart';
import 'package:portachip/CPU/CPU.dart';
import 'Display.dart';
import 'package:portachip/Input/KeyState.dart';
import 'package:portachip/UI/HomePage.dart';

class ProgramView extends StatefulWidget {
  final CPU cpu;

  const ProgramView({super.key, required this.cpu});

  @override
  State<ProgramView> createState() => _ProgramViewState();
}

class _ProgramViewState extends State<ProgramView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showDebugInfo = false;
  FocusNode _keyNode = FocusNode();

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(
          microseconds:
              Provider.of<StateNotifier>(context, listen: false).refreshDelay),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    _keyNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_keyNode);
    return RawKeyboardListener(
      focusNode: _keyNode,
      onKey: (RawKeyEvent event) {
        // KeyState.handleKeyInput(event, cpu);
      },
      child: StatsFl(
        isEnabled: Provider.of<StateNotifier>(context, listen: false).showFPS,
        align: Alignment.topLeft,
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Column(
              children: [
                // const Expanded(child: SizedBox()),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 2 / 1,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (BuildContext context, Widget? child) {
                          if (!Provider.of<StateNotifier>(context,
                                  listen: false)
                              .isPaused) widget.cpu.emulateCycle();
                          return CustomPaint(
                            willChange: true,
                            painter: Display(
                                cpu: widget.cpu,
                                listenable: _controller,
                                scale: Provider.of<StateNotifier>(context,
                                        listen: false)
                                    .upscale),
                            size: MediaQuery.of(context).size,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Footer(
                  pause: () {
                    setState(() {
                      Provider.of<StateNotifier>(context, listen: false)
                              .isPaused =
                          !Provider.of<StateNotifier>(context, listen: false)
                              .isPaused;
                    });
                  },
                  stop: () {
                    Provider.of<StateNotifier>(context, listen: false)
                        .isPaused = true;
                    widget.cpu.initialize();
                    Future.delayed(Duration.zero, () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: const HomePage()),
                          (Route<dynamic> route) => false);
                      Provider.of<StateNotifier>(context, listen: false)
                          .isPaused = false;
                    });
                  },
                  fps: () {
                    setState(() {
                      Provider.of<StateNotifier>(context, listen: false)
                              .showFPS =
                          !Provider.of<StateNotifier>(context, listen: false)
                              .showFPS;
                    });
                  },
                ),
              ],
            )),
      ),
    );
  }
}
