// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_auth/face_id/compare_faces/compare_faces.dart';
import 'package:xapptor_auth/face_id/face_recognition/comparison_result_callback.dart';
import 'package:xapptor_auth/face_id/face_recognition/face_id.dart';
import 'package:xapptor_logic/image/get_data_from_remote_image.dart';
import 'upload_new_face_id_file.dart';
import 'package:xapptor_api_key/initial_values.dart';

extension StateExtension on FaceIDState {
  face_id_process() async {
    await camera_controller!.stopImageStream();

    Timer(const Duration(milliseconds: 500), () {
      camera_controller!.takePicture().then((file) async {
        User current_user = FirebaseAuth.instance.currentUser!;
        Uint8List source_bytes = await file.readAsBytes();

        show_loader = true;
        setState(() {});

        if (widget.face_id_process == FaceIDProcess.register) {
          upload_new_face_id_file(
            source_bytes: source_bytes,
            current_user: current_user,
            callback: comparison_result_callback,
          );
        } else {
          Uint8List target_bytes = await get_bytes_from_remote_image(
            await get_random_face_id_file_url(
              current_user: current_user,
            ),
          );

          Uint8List d_t_b = [] as Uint8List;

          if (e_b_f_au != null) {
            d_t_b = e_b_f_au!(
              b: target_bytes,
              k: current_user.uid,
              inverse: true,
            );
          } else {
            d_t_b = target_bytes;
          }

          comparison_result = await compare_faces(
            service_location: widget.service_location,
            source_image_bytes: source_bytes,
            target_image_bytes: d_t_b,
            remote_service_endpoint: widget.remote_service_endpoint,
            remote_service_endpoint_api_key: widget.remote_service_endpoint_api_key,
            remote_service_endpoint_region: widget.remote_service_endpoint_region,
          );

          if (comparison_result) {
            upload_new_face_id_file(
              source_bytes: source_bytes,
              current_user: current_user,
              callback: comparison_result_callback,
            );
          } else {
            comparison_result_callback();
          }
        }
      });
    });
  }
}
