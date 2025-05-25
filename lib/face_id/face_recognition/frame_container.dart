import 'package:flutter/material.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id.dart';

extension StateExtension on FaceIDState {
  frame_container({
    required double screen_width,
    required double screen_height,
    required double outline_border_radius,
  }) =>
      Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          bottom: screen_height * (animation_controller.value <= 0.46 ? 0.4 : 0.5),
        ),
        constraints: BoxConstraints(
          maxHeight: 50,
          maxWidth: screen_width * 0.65,
        ),
        decoration: BoxDecoration(
          color: widget.main_color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.all(
            Radius.circular(outline_border_radius),
          ),
        ),
        child: Text(
          frame_toast_text,
          style: const TextStyle(
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      );
}
