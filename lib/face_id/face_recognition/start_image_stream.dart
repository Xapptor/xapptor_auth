import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:xapptor_auth/face_id/face_recognition/convert_image_to_input_image.dart';

start_image_stream({
  required CameraController camera_controller,
  required CameraDescription camera,
  required Function process_image_function,
}) {
  camera_controller.startImageStream((CameraImage camera_image) async {
    InputImage input_image = convert_camera_image_to_input_image(
      image: camera_image,
      camera: camera,
    );
    process_image_function(input_image);
  });
}
