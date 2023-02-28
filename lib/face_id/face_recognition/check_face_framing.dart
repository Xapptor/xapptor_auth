import 'dart:html';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

check_face_framing({
  required Face face,
  required bool pass_first_face_detection,
  required Function update_face_distance_result_2,
  required Function update_framing_values,
  required Function callback,
}) {
  if (face.smilingProbability! < 0.1) {
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

    FaceLandmark? left_eye = face.landmarks[FaceLandmarkType.leftEye];
    FaceLandmark? nose_base = face.landmarks[FaceLandmarkType.noseBase];
    FaceLandmark? left_cheek = face.landmarks[FaceLandmarkType.leftCheek];
    FaceLandmark? right_cheek = face.landmarks[FaceLandmarkType.rightCheek];
    FaceLandmark? bottom_mouth = face.landmarks[FaceLandmarkType.bottomMouth];

    Point left_eye_position = left_eye?.position ?? Point(0, 0);
    Point nose_base_position = nose_base?.position ?? Point(0, 0);
    Point left_cheek_position = left_cheek?.position ?? Point(0, 0);
    Point right_cheek_position = right_cheek?.position ?? Point(0, 0);
    Point bottom_mouth_position = bottom_mouth?.position ?? Point(0, 0);

    double distance_between_cheeks =
        (right_cheek_position.x - left_cheek_position.x).abs().toDouble();

    double distance_between_mouth_and_eye =
        (bottom_mouth_position.y - left_eye_position.y).abs().toDouble();

    double face_distance =
        (distance_between_cheeks + distance_between_mouth_and_eye).abs();

    bool face_distance_result_1 = face_distance >= min_face_distance_1 &&
        face_distance <= max_face_distance_1;

    bool face_distance_result_2 = face_distance >= min_face_distance_2 &&
        face_distance <= max_face_distance_2;

    update_face_distance_result_2(face_distance_result_2);

    bool nose_base_y_position_result_1 = nose_base_position.y >= nose_min_y_1 &&
        nose_base_position.y <= nose_max_y_1;

    bool nose_base_y_position_result_2 = nose_base_position.y >= nose_min_y_2 &&
        nose_base_position.y <= nose_max_y_2;

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
  } else {
    update_framing_values(
      false,
      false,
      "Do Not Smile",
      true,
    );
  }
  callback();
}
