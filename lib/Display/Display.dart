import 'package:flutter/material.dart';
import '../CPU/CPU.dart';

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
          // * 1.025 is a workaround to get rid of black lines in the grid
          painter.color = Colors.black;
        } else {
          painter.color = Colors.white;
        }
        canvas.drawRect(
            Rect.fromLTWH(c * recWidth, r * recHeight, recWidth * 1.025,
                recHeight * 1.025),
            painter);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => this != oldDelegate;
}
