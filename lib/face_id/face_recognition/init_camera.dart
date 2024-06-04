// ignore_for_file: invalid_use_of_protected_member

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_auth/face_id/face_recognition/convert_image_to_input_image.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id.dart';
import 'package:xapptor_auth/face_id/face_recognition/process_image.dart';

extension StateExtension on FaceIDState {
  init_camera() async {
    cameras = await availableCameras();

    camera_controller = CameraController(
      cameras[widget.front_camera ? 1 : 0],
      widget.front_camera ? ResolutionPreset.high : ResolutionPreset.medium,
    );
    await camera_controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      init_timer();

      if (UniversalPlatform.isMobile) {
        camera_controller!.startImageStream((CameraImage camera_image) async {
          InputImage input_image = convert_camera_image_to_input_image(
            image: camera_image,
            camera: cameras[widget.front_camera ? 1 : 0],
          );
          process_image(input_image);
        });
      }
    });
  }
}
