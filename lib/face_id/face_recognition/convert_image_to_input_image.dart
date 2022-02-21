import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

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
  final bytes = all_bytes.done().buffer.asUint8List();

  final Size image_size = Size(image.width.toDouble(), image.height.toDouble());

  final InputImageRotation image_rotation =
      InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.Rotation_0deg;

  final InputImageFormat input_image_format =
      InputImageFormatMethods.fromRawValue(image.format.raw) ??
          InputImageFormat.NV21;

  final plane_data = image.planes.map(
    (Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    },
  ).toList();

  final input_image_data = InputImageData(
    size: image_size,
    imageRotation: image_rotation,
    inputImageFormat: input_image_format,
    planeData: plane_data,
  );

  InputImage input_image = InputImage.fromBytes(
    bytes: image.planes.first.bytes,
    inputImageData: input_image_data,
  );
  return input_image;
}
