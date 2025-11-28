import 'package:flutter/material.dart';
import 'package:xapptor_ui/values/ui.dart';

class FaceFramePainter extends CustomPainter {
  const FaceFramePainter({
    required this.main_color,
    required this.oval_size_multiplier,
  });

  final Color main_color;
  final double oval_size_multiplier;

  @override
  void paint(Canvas canvas, Size size) {
    double oval_height = size.height * oval_size_multiplier;
    double oval_width = (size.width * oval_size_multiplier) * 1.1;

    Paint hole_paint = Paint()..color = Colors.white;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRRect(
            RRect.fromLTRBR(
              0,
              0,
              size.width,
              size.height,
              const Radius.circular(outline_border_radius),
            ),
          ),
        Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(
                size.width / 2,
                size.height / 2,
              ),
              width: oval_width,
              height: oval_height,
            ),
          )
          ..close(),
      ),
      hole_paint,
    );

    Paint border_paint = Paint()
      ..color = main_color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 50;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width / 2,
          size.height / 2,
        ),
        width: oval_width,
        height: oval_height,
      ),
      border_paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
