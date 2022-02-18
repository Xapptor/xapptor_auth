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
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in camera_image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(camera_image.width.toDouble(), camera_image.height.toDouble());

    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(cameras[1].sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(camera_image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = camera_image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    InputImage input_image = InputImage.fromBytes(
        bytes: camera_image.planes.first.bytes, inputImageData: inputImageData);

    process_image_function(input_image);
  });
}
