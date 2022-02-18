import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'get_face_id.dart';

check_face_framing({
  required Face face,
  required BuildContext context,
  required bool pass_first_face_detection,
  required Function update_face_distance_result_2,
  required Function update_framing_values,
  required Function callback,
}) {
  int min_face_distance_1 = 400;
  int max_face_distance_1 = 500;

  int min_face_distance_2 = 800;
  int max_face_distance_2 = 1000;

  int nose_min_x = 300;
  int nose_max_x = 400;

  int nose_min_y_1 = 620;
  int nose_max_y_1 = 720;

  int nose_min_y_2 = 600;
  int nose_max_y_2 = 800;

  FaceLandmark? left_eye = face.getLandmark(FaceLandmarkType.leftEye);
  FaceLandmark? nose_base = face.getLandmark(FaceLandmarkType.noseBase);
  FaceLandmark? left_cheek = face.getLandmark(FaceLandmarkType.leftCheek);
  FaceLandmark? right_cheek = face.getLandmark(FaceLandmarkType.rightCheek);
  FaceLandmark? bottom_mouth = face.getLandmark(FaceLandmarkType.bottomMouth);

  Offset left_eye_position = left_eye?.position ?? Offset.zero;
  Offset nose_base_position = nose_base?.position ?? Offset.zero;
  Offset left_cheek_position = left_cheek?.position ?? Offset.zero;
  Offset right_cheek_position = right_cheek?.position ?? Offset.zero;
  Offset bottom_mouth_position = bottom_mouth?.position ?? Offset.zero;

  double distance_between_cheeks =
      (right_cheek_position.dx - left_cheek_position.dx).abs();

  double distance_between_mouth_and_eye =
      (bottom_mouth_position.dy - left_eye_position.dy).abs();

  double face_distance =
      (distance_between_cheeks + distance_between_mouth_and_eye).abs();

  bool face_distance_result_1 = face_distance >= min_face_distance_1 &&
      face_distance <= max_face_distance_1;

  bool face_distance_result_2 = face_distance >= min_face_distance_2 &&
      face_distance <= max_face_distance_2;

  update_face_distance_result_2(face_distance_result_2);

  bool nose_base_y_position_result_1 = nose_base_position.dy >= nose_min_y_1 &&
      nose_base_position.dy <= nose_max_y_1;

  bool nose_base_y_position_result_2 = nose_base_position.dy >= nose_min_y_2 &&
      nose_base_position.dy <= nose_max_y_2;

  if (!pass_first_face_detection) {
    if (face_distance_result_1 && nose_base_y_position_result_1) {
      update_framing_values(
        true,
        false,
        "",
        false,
      );
    } else {
      update_framing_values(
        false,
        false,
        "Frame Your Face",
        true,
      );
    }
  } else {
    if (nose_base_y_position_result_2) {
      if (face_distance_result_2 && pass_first_face_detection) {
        update_framing_values(
          true,
          true,
          "",
          false,
        );
        get_face_id(face: face);
        Navigator.pop(context);
      } else {
        update_framing_values(
          false,
          false,
          face_distance < min_face_distance_2
              ? "Move Closer"
              : "Frame Your Face",
          true,
        );
      }
    } else {
      update_framing_values(
        false,
        false,
        "Frame Your Face",
        true,
      );
    }
  }
  callback();
}
