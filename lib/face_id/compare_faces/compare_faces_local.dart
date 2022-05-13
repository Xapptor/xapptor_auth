import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/face_id/face_recognition/convert_image_to_input_image.dart';
import 'package:xapptor_logic/get_temporary_file_from_local.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

Future<bool> compare_faces_with_local_service({
  required Uint8List source_image_bytes,
  required Uint8List target_image_bytes,
}) async {
  final face_detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableContours: false,
      enableClassification: true,
    ),
  );

  File source_file = await get_temporary_file_from_local(
    bytes: source_image_bytes,
    name: "temp_image_1.jpeg",
  );

  File target_file = await get_temporary_file_from_local(
    bytes: target_image_bytes,
    name: "temp_image_2.jpeg",
  );

  InputImage source_input_image = await convert_image_file_to_input_image(
    file: source_file,
  );

  InputImage target_input_image = await convert_image_file_to_input_image(
    file: target_file,
  );

  final source_faces = await face_detector.processImage(source_input_image);
  final target_faces = await face_detector.processImage(target_input_image);

  List<int> source_face_offset_distances = [];
  List<int> target_face_offset_distances = [];

  bool face_match = false;

  if (source_faces.length > 0) {
    source_face_offset_distances =
        get_face_offset_distances(face: source_faces.first);
  }

  if (target_faces.length > 0) {
    target_face_offset_distances =
        get_face_offset_distances(face: target_faces.first);
  }

  if (source_face_offset_distances.isNotEmpty &&
      target_face_offset_distances.isNotEmpty) {
    face_match = validate_face_id(
      offset_distances_source: source_face_offset_distances,
      offset_distances_target: target_face_offset_distances,
    );
  }
  return face_match;
}

List<int> get_face_offset_distances({
  required Face face,
}) {
  FaceLandmark? left_eye = face.landmarks[FaceLandmarkType.leftEye];
  FaceLandmark? right_eye = face.landmarks[FaceLandmarkType.rightEye];

  FaceLandmark? nose_base = face.landmarks[FaceLandmarkType.noseBase];

  FaceLandmark? left_cheek = face.landmarks[FaceLandmarkType.leftCheek];
  FaceLandmark? right_cheek = face.landmarks[FaceLandmarkType.rightCheek];

  FaceLandmark? left_mouth = face.landmarks[FaceLandmarkType.leftMouth];
  FaceLandmark? right_mouth = face.landmarks[FaceLandmarkType.rightMouth];
  FaceLandmark? bottom_mouth = face.landmarks[FaceLandmarkType.bottomMouth];

  Point<int> left_eye_position = left_eye?.position ?? Point(0, 0);
  Point<int> right_eye_position = right_eye?.position ?? Point(0, 0);

  Point<int> nose_base_position = nose_base?.position ?? Point(0, 0);

  Point<int> left_cheek_position = left_cheek?.position ?? Point(0, 0);
  Point<int> right_cheek_position = right_cheek?.position ?? Point(0, 0);

  Point<int> left_mouth_position = left_mouth?.position ?? Point(0, 0);
  Point<int> right_mouth_position = right_mouth?.position ?? Point(0, 0);
  Point<int> bottom_mouth_position = bottom_mouth?.position ?? Point(0, 0);

  List<Point> offset_list_1 = [
    left_eye_position,
    right_eye_position,
    left_cheek_position,
    right_cheek_position,
    left_mouth_position,
    right_mouth_position,
  ];

  List<Point> offset_list_2 = [
    left_eye_position,
    left_cheek_position,
    right_eye_position,
    right_cheek_position,
    nose_base_position,
    bottom_mouth_position,
  ];

  List<Point> offset_list_3 = [
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
  required List<Point> offset_list,
}) {
  List<int> offset_distances = [];
  for (var i = 0; i < offset_list.length; i += 2) {
    offset_distances
        .add((offset_list[i].distanceTo(offset_list[i + 1]).round()));
  }
  return offset_distances;
}

bool validate_face_id({
  required List<int> offset_distances_source,
  required List<int> offset_distances_target,
}) {
  List<bool> similarity_list = [];

  for (var i = 0; i < offset_distances_source.length; i++) {
    similarity_list.add(
        (offset_distances_source[i] - offset_distances_target[i]).abs() < 25);
  }

  double valid_face_percentage =
      (100 * similarity_list.where((item) => item == true).length) /
          offset_distances_source.length;

  print("Similarity: " + valid_face_percentage.toString());
  bool valid_face = valid_face_percentage == 100;
  return valid_face;
}
