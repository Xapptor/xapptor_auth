// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:xapptor_auth/face_id/face_recognition/analize_for_face_changes.dart';
import 'package:xapptor_auth/face_id/face_recognition/check_face_framing.dart';
import 'package:xapptor_auth/face_id/face_recognition/check_liveness.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id_process.dart';

extension StateExtension on FaceIDState {
  Future process_image(InputImage input_image) async {
    if (is_busy) return;
    is_busy = true;
    process_image_counter++;

    final faces = await face_detector.processImage(input_image);

    if (faces.isNotEmpty) {
      Face first_face = faces.first;

      if (liveness_test_passed) {
        debugPrint("-------------------------PASSED!-------------------------");
      } else {
        check_liveness(
            face: first_face,
            update_function: (
              new_smiling_probability_list,
              new_left_eye_open_probability_list,
              new_right_eye_open_probability_list,
            ) {
              smiling_probability_list = new_smiling_probability_list;
              left_eye_open_probability_list = new_left_eye_open_probability_list;
              right_eye_open_probability_list = new_right_eye_open_probability_list;

              //Analize for changes

              smiling_probability_test_passed = analize_for_face_changes(smiling_probability_list);

              left_eye_open_probability_test_passed = analize_for_face_changes(left_eye_open_probability_list);

              right_eye_open_probability_test_passed = analize_for_face_changes(right_eye_open_probability_list);

              if (left_eye_open_probability_test_passed && right_eye_open_probability_test_passed) {
                liveness_test_passed = true;
              }
            });
      }

      if (process_image_counter % 3 == 0) {
        process_image_counter = 0;

        check_face_framing(
          face: first_face,
          pass_first_face_detection: pass_first_face_detection,
          update_face_distance_result_2: (
            bool new_face_distance_result_2,
          ) {
            face_distance_result_2 = new_face_distance_result_2;
          },
          update_framing_values: (
            bool new_face_is_ready_to_init_scan,
            bool new_face_is_close_enough,
            String new_frame_toast_text,
            bool new_show_frame_toast,
          ) {
            face_is_ready_to_init_scan = new_face_is_ready_to_init_scan;
            face_is_close_enough = new_face_is_close_enough;
            frame_toast_text = new_frame_toast_text;
            show_frame_toast = new_show_frame_toast;
          },
          callback: () {
            setState(() {});
            if (face_distance_result_2 && pass_first_face_detection) {
              face_id_process();
            }
          },
        );
      }
    } else {
      face_is_ready_to_init_scan = false;
      face_is_close_enough = false;
      frame_toast_text = "Frame Your Face";
      show_frame_toast = true;
      setState(() {});
    }
    is_busy = false;
  }
}
