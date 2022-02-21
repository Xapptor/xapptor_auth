import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:xapptor_auth/face_id/face_recognition/convert_image_to_input_image.dart';
import 'package:xapptor_logic/get_temporary_file_from_remote_image.dart';

Future<bool> compare_faces_with_local_service({
  required String source_image_base64,
  required String target_image_base64,
}) async {
  FaceDetector face_detector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      mode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableContours: false,
      enableClassification: true,
    ),
  );

  File file = await get_temporary_file_from_remote_image(
      "https://firebasestorage.googleapis.com/v0/b/xapptor.appspot.com/o/face_id_test%2Fface_id_test_2.jpeg?alt=media&token=88006dc3-69af-48e4-b3d9-b9c0c44786bd");
  InputImage input_image = await convert_image_file_to_input_image(
    file: file,
  );

  final faces = await face_detector.processImage(input_image);

  bool face_match = false;

  if (faces.length > 0) {
    List<int> face_offset_distances =
        get_face_offset_distances(face: faces.first);
  }
  return face_match;
}

List<int> get_face_offset_distances({
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
      get_offset_distances(offset_list: offset_list_1);

  List<int> offset_distances_2 =
      get_offset_distances(offset_list: offset_list_2);

  List<int> offset_distances_3 =
      get_offset_distances(offset_list: offset_list_3);

  List<int> offset_distances =
      offset_distances_1 + offset_distances_2 + offset_distances_3;

  return offset_distances;
}

List<int> get_offset_distances({
  required List<Offset> offset_list,
}) {
  List<int> offset_distances = [];
  for (var i = 0; i < offset_list.length; i += 2) {
    offset_distances
        .add((offset_list[i] - offset_list[i + 1]).distance.round());
  }
  return offset_distances;
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
