import 'package:flutter/material.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id.dart';

extension StateExtension on FaceIDState {
  comparison_result_container({
    required double screen_width,
  }) =>
      FractionallySizedBox(
        heightFactor: 0.2,
        widthFactor: 0.2,
        child: AnimatedContainer(
          curve: Curves.easeInOutCubicEmphasized,
          duration: const Duration(milliseconds: 900),
          decoration: BoxDecoration(
            color: widget.main_color.withValues(alpha: comparison_result_animate ? 1 : 0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            comparison_result ? Icons.check : Icons.close,
            color: Colors.white.withValues(alpha: comparison_result_animate ? 1 : 0),
            size: screen_width * 0.1,
          ),
        ),
      );
}
