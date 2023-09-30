import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

Future<InputImage> convert_image_file_to_input_image({
  required File file,
}) async {
  InputImage input_image = InputImage.fromFile(file);
  return input_image;
}

InputImage convert_camera_image_to_input_image({
  required CameraImage image,
  required CameraDescription camera,
}) {
  final WriteBuffer all_bytes = WriteBuffer();
  for (Plane plane in image.planes) {
    all_bytes.putUint8List(plane.bytes);
  }
  //final bytes = all_bytes.done().buffer.asUint8List();

  final Size image_size = Size(image.width.toDouble(), image.height.toDouble());

  final InputImageRotation image_rotation =
      InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;

  final InputImageFormat input_image_format = image.format.raw ?? InputImageFormat.nv21;

  final input_image_data = InputImageMetadata(
    size: image_size,
    rotation: image_rotation,
    format: input_image_format,
    bytesPerRow: image.planes.first.bytesPerRow,
  );

  InputImage input_image = InputImage.fromBytes(
    bytes: image.planes.first.bytes,
    metadata: input_image_data,
  );
  return input_image;
}
