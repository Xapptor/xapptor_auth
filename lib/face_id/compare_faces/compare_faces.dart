import 'package:xapptor_logic/random_number_with_range.dart';
import 'compare_faces_local.dart';
import 'compare_faces_remote.dart';
import 'dart:typed_data';

enum ServiceLocation {
  local,
  remote,
  random,
}

Future<bool> compare_faces({
  required ServiceLocation service_location,
  required Uint8List source_image_bytes,
  required Uint8List target_image_bytes,
}) async {
  switch (service_location) {
    case ServiceLocation.local:
      return await compare_faces_with_local_service(
        source_image_bytes: source_image_bytes,
        target_image_bytes: target_image_bytes,
      );

    case ServiceLocation.remote:
      return await compare_faces_with_remote_service(
        source_image_bytes: source_image_bytes,
        target_image_bytes: target_image_bytes,
      );
    case ServiceLocation.random:
      int random_number = random_number_with_range(0, 9);
      if (random_number == 2 || random_number == 5 || random_number == 8) {
        return await compare_faces_with_remote_service(
          source_image_bytes: source_image_bytes,
          target_image_bytes: target_image_bytes,
        );
      } else {
        return await compare_faces_with_local_service(
          source_image_bytes: source_image_bytes,
          target_image_bytes: target_image_bytes,
        );
      }
  }
}
