import 'package:flutter/material.dart';

class FaceFramePainter extends CustomPainter {
  const FaceFramePainter({
    required this.border_color,
    required this.frame_height,
    required this.frame_width,
  });

  final Color border_color;
  final double frame_height;
  final double frame_width;

  @override
  void paint(Canvas canvas, Size size) {
    Paint hole_paint = Paint()..color = Colors.white;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRRect(
            RRect.fromLTRBR(
              0,
              0,
              frame_width,
              frame_height,
              Radius.circular(0),
            ),
          ),
        Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(
                frame_width / 2,
                frame_height / 2,
              ),
              width: frame_width,
              height: frame_height,
            ),
          )
          ..close(),
      ),
      hole_paint,
    );

    Paint border_paint = Paint()
      ..color = border_color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 40;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          frame_width / 2,
          frame_height / 2,
        ),
        width: frame_width,
        height: frame_height,
      ),
      border_paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
