// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_auth/face_id/face_recognition/face_id.dart';

extension StateExtension on FaceIDState {
  on_main_feedback_button_pressed() {
    minimize_frame = false;
    pass_first_face_detection = true;
    setState(() {});
    animation_controller.forward();
    if (!timer_was_restart) {
      timer_was_restart = true;
      session_life_time_timer.cancel();
      init_timer();
    }
  }
}
