import 'package:flutter/material.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id.dart';

extension StateExtension on FaceIDState {
  face_id_loader({
    required double screen_width,
  }) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: screen_width / 7,
            width: screen_width / 7,
            margin: const EdgeInsets.only(bottom: 20),
            child: CircularProgressIndicator(
              color: widget.main_color,
              strokeWidth: screen_width / 60,
            ),
          ),
          Text(
            "Uploading Encrypted Face Points",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.main_color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
