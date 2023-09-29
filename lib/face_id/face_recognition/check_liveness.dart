import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

check_liveness({
  required Face face,
  required Function update_function,
}) {
  List<double> smiling_probability_list = [];
  List<double> left_eye_open_probability_list = [];
  List<double> right_eye_open_probability_list = [];

  // Adding probabilities

  if (face.smilingProbability != null) {
    smiling_probability_list.add(face.smilingProbability!);
  }

  if (face.leftEyeOpenProbability != null) {
    left_eye_open_probability_list.add(face.leftEyeOpenProbability!);
  }

  if (face.rightEyeOpenProbability != null) {
    right_eye_open_probability_list.add(face.rightEyeOpenProbability!);
  }

  // Check list length

  if (smiling_probability_list.length > 20) {
    smiling_probability_list.removeAt(0);
  }

  if (left_eye_open_probability_list.length > 20) {
    left_eye_open_probability_list.removeAt(0);
  }

  if (right_eye_open_probability_list.length > 20) {
    right_eye_open_probability_list.removeAt(0);
  }

  update_function(
    smiling_probability_list,
    left_eye_open_probability_list,
    right_eye_open_probability_list,
  );
}
