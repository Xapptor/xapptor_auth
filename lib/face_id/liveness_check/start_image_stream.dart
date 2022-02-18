import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

start_image_stream({
  required CameraController camera_controller,
  required List<CameraDescription> cameras,
  required Function process_image_function,
}) {
  camera_controller.startImageStream((CameraImage camera_image) {
    final WriteBuffer all_bytes = WriteBuffer();
    for (Plane plane in camera_image.planes) {
      all_bytes.putUint8List(plane.bytes);
    }
    final bytes = all_bytes.done().buffer.asUint8List();

    final Size image_size =
        Size(camera_image.width.toDouble(), camera_image.height.toDouble());

    final InputImageRotation image_rotation =
        InputImageRotationMethods.fromRawValue(cameras[1].sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat input_image_format =
        InputImageFormatMethods.fromRawValue(camera_image.format.raw) ??
            InputImageFormat.NV21;

    final plane_data = camera_image.planes.map(
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
        bytes: camera_image.planes.first.bytes,
        inputImageData: input_image_data);

    process_image_function(input_image);
  });
}
