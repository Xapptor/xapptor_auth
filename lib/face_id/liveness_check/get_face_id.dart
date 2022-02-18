import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

String get_face_id({
  required Face face,
}) {
  FaceLandmark? left_eye = face.getLandmark(FaceLandmarkType.leftEye);
  FaceLandmark? right_eye = face.getLandmark(FaceLandmarkType.rightEye);

  FaceLandmark? nose_base = face.getLandmark(FaceLandmarkType.noseBase);

  FaceLandmark? left_cheek = face.getLandmark(FaceLandmarkType.leftCheek);
  FaceLandmark? right_cheek = face.getLandmark(FaceLandmarkType.rightCheek);

  FaceLandmark? left_mouth = face.getLandmark(FaceLandmarkType.leftMouth);
  FaceLandmark? right_mouth = face.getLandmark(FaceLandmarkType.rightMouth);
  FaceLandmark? bottom_mouth = face.getLandmark(FaceLandmarkType.bottomMouth);

  Offset left_eye_position = left_eye?.position ?? Offset.zero;
  Offset right_eye_position = right_eye?.position ?? Offset.zero;

  Offset nose_base_position = nose_base?.position ?? Offset.zero;

  Offset left_cheek_position = left_cheek?.position ?? Offset.zero;
  Offset right_cheek_position = right_cheek?.position ?? Offset.zero;

  Offset left_mouth_position = left_mouth?.position ?? Offset.zero;
  Offset right_mouth_position = right_mouth?.position ?? Offset.zero;
  Offset bottom_mouth_position = bottom_mouth?.position ?? Offset.zero;

  List<Offset> offset_list_1 = [
    left_eye_position,
    right_eye_position,
    left_cheek_position,
    right_cheek_position,
    left_mouth_position,
    right_mouth_position,
  ];

  List<Offset> offset_list_2 = [
    left_eye_position,
    left_cheek_position,
    right_eye_position,
    right_cheek_position,
    nose_base_position,
    bottom_mouth_position,
  ];

  List<Offset> offset_list_3 = [
    left_eye_position,
    right_cheek_position,
    right_eye_position,
    left_cheek_position,
    left_eye_position,
    right_mouth_position,
    right_eye_position,
    left_mouth_position,
  ];

  List<int> offset_distances_1 =
      get_offset_distances_from_nose_base(offset_list: offset_list_1);

  List<int> offset_distances_2 =
      get_offset_distances_from_nose_base(offset_list: offset_list_2);

  List<int> offset_distances_3 =
      get_offset_distances_from_nose_base(offset_list: offset_list_3);

  List<int> offset_distances =
      offset_distances_1 + offset_distances_2 + offset_distances_3;

  int offset_distances_sum_1 =
      offset_distances_1.reduce((value, element) => value + element);

  int offset_distances_sum_2 =
      offset_distances_2.reduce((value, element) => value + element);

  int offset_distances_sum_3 =
      offset_distances_3.reduce((value, element) => value + element);

  List<int> offset_distances_example_1 = [310, 440, 280];
  List<int> offset_distances_example_2 = [245, 240, 250];
  List<int> offset_distances_example_3 = [440, 440, 465, 465];

  //List<int> offset_distances_example = [310, 440, 280] + [245, 240, 250] + [440, 440, 465, 465];
  List<int> offset_distances_example = offset_distances_example_1 +
      offset_distances_example_2 +
      offset_distances_example_3;

  print("------------offset_distances------------");
  print(offset_distances_example);
  print(offset_distances);

  bool valid_face = validate_face_id(
    offset_distances_original: offset_distances_example,
    offset_distances_new: offset_distances,
  );

  print(valid_face);

  set_face_keys_to_current_user(offset_distances_new: offset_distances_example);

  return "test";
}

set_face_keys_to_current_user({
  required List<int> offset_distances_new,
}) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc("FcqQqDVf8FNmF9tw1TsmZhykr8G3")
      .update({
    "face_keys": offset_distances_new,
  });
}

bool validate_face_id({
  required List<int> offset_distances_original,
  required List<int> offset_distances_new,
}) {
  List<bool> similarity_list = [];

  for (var i = 0; i < offset_distances_original.length; i++) {
    similarity_list.add(
        (offset_distances_original[i] - offset_distances_new[i]).abs() < 21);
  }

  double valid_face_percentage =
      (100 * similarity_list.where((item) => item == true).length) /
          offset_distances_original.length;

  print(valid_face_percentage);

  bool valid_face = valid_face_percentage == 100;
  return valid_face;
}

List<int> get_offset_distances_from_nose_base({
  required List<Offset> offset_list,
}) {
  List<int> offset_distances = [];
  for (var i = 0; i < offset_list.length; i += 2) {
    offset_distances
        .add((offset_list[i] - offset_list[i + 1]).distance.round());
  }
  return offset_distances;
}
