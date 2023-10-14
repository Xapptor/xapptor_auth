// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/widgets.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id.dart';

extension StateExtension on FaceIDState {
  init_animation() async {
    animation_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    Animation<double> animation_curve = CurvedAnimation(
      parent: animation_controller,
      curve: Curves.elasticOut,
    );

    animation = oval_size_multiplier.animate(animation_curve)
      ..addListener(() {
        setState(() {});
      });
  }
}
