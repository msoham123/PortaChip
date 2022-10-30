import 'package:flutter/material.dart';
import '../CPU/CPU.dart';

class Display extends CustomPainter {
  final Animation listenable;
  CPU cpu;
  var painter = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;
  int scale;

  Display({required this.cpu, required this.listenable, required this.scale})
      : super(repaint: listenable);

  @override
  void paint(Canvas canvas, Size size) {
    List<List<bool>> scaledDisplay = List.generate(CPU.screenHeight * scale,
        (_) => List.filled(CPU.screenWidth * scale, false));

    for (int r = 0; r < CPU.screenHeight; r++) {
      for (int c = 0; c < CPU.screenWidth; c++) {
        if (scale == 2) {
          scaledDisplay[r * scale][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 1][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 1] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 1][(c * scale) + 1] =
              cpu.getDisplayState(r, c);
        } else if (scale == 4) {
          // HARD CODED for 4x
          scaledDisplay[r * scale][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 1][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 1] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 1][(c * scale) + 1] =
              cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 2][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 2] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 2][(c * scale) + 2] =
              cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 3][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 3] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 3][(c * scale) + 3] =
              cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 1][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 2] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 1][(c * scale) + 2] =
              cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 3][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 2] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 3][(c * scale) + 2] =
              cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 3][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 1] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 3][(c * scale) + 1] =
              cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 2][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 1] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 2][(c * scale) + 1] =
              cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 2][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 3] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 2][(c * scale) + 3] =
              cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 1][c * scale] = cpu.getDisplayState(r, c);
          scaledDisplay[r * scale][(c * scale) + 3] = cpu.getDisplayState(r, c);
          scaledDisplay[(r * scale) + 1][(c * scale) + 3] =
              cpu.getDisplayState(r, c);
        } else {
          scale = 1;
          scaledDisplay[r][c] = cpu.getDisplayState(r, c);
        }
      }
    }

    double recWidth = size.width / (CPU.screenWidth * scale);
    double recHeight = size.height / (CPU.screenHeight * scale);

    for (int r = 0; r < CPU.screenHeight * scale; r++) {
      for (int c = 0; c < CPU.screenWidth * scale; c++) {
        if (!scaledDisplay[r][c]) {
          // * 1.25 is a workaround to get rid of black lines in the grid
          painter.color = Colors.black;
        } else {
          painter.color = Colors.white;
        }
        canvas.drawRect(
            Rect.fromLTWH(
                c * recWidth, r * recHeight, recWidth * 1.25, recHeight * 1.25),
            painter);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => this != oldDelegate;
}
