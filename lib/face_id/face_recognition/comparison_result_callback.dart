// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/face_id/compare_faces/compare_faces.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id.dart';

extension StateExtension on FaceIDState {
  comparison_result_callback() {
    Timer(Duration(milliseconds: widget.service_location == ServiceLocation.local ? 2000 : 0), () {
      show_loader = false;
      show_comparison_result = true;
      setState(() {});
      Timer(const Duration(milliseconds: 300), () {
        comparison_result_animate = true;
        setState(() {});
        Timer(const Duration(milliseconds: 3500), () {
          Navigator.pop(context);
        });
      });
    });
  }
}
