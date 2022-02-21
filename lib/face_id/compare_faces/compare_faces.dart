import 'compare_faces_local.dart';
import 'compare_faces_remote.dart';

enum ServiceLocation {
  local,
  remote,
}

Future<bool> compare_faces({
  required ServiceLocation service_location,
  required String source_image_base64,
  required String target_image_base64,
}) async {
  if (service_location == ServiceLocation.local) {
    return await compare_faces_with_local_service(
      source_image_base64: source_image_base64,
      target_image_base64: target_image_base64,
    );
  } else {
    return await compare_faces_with_remote_service(
      source_image_base64: source_image_base64,
      target_image_base64: target_image_base64,
    );
  }
}

test_compare_faces_remote() async {
  // List image_urls = [
  //   "https://firebasestorage.googleapis.com/v0/b/xapptor.appspot.com/o/face_id_test%2Fface_id_test_1.jpeg?alt=media&token=b5fac51d-4c6d-4737-8d4e-490dcc35a75a",
  //   "https://firebasestorage.googleapis.com/v0/b/xapptor.appspot.com/o/face_id_test%2Fface_id_test_2.jpeg?alt=media&token=88006dc3-69af-48e4-b3d9-b9c0c44786bd",
  //   "https://firebasestorage.googleapis.com/v0/b/xapptor.appspot.com/o/face_id_test%2Fface_id_test_3.jpeg?alt=media&token=b257c0dd-1fb6-4558-ae5e-ae74643ba7fc",
  //   "https://firebasestorage.googleapis.com/v0/b/xapptor.appspot.com/o/face_id_test%2Fface_id_test_4.jpeg?alt=media&token=d92ab3e0-7a0c-4b2a-81d7-551238d305fd",
  //   "https://firebasestorage.googleapis.com/v0/b/xapptor.appspot.com/o/face_id_test%2Fface_id_test_5.jpeg?alt=media&token=7ec56c1d-3c7d-4b90-8b37-408263a784de",
  //   "https://firebasestorage.googleapis.com/v0/b/xapptor.appspot.com/o/face_id_test%2Fface_id_test_6.jpeg?alt=media&token=9cd53b57-62a9-4d24-a1af-fe38c4348827",
  //   "https://firebasestorage.googleapis.com/v0/b/xapptor.appspot.com/o/face_id_test%2Fface_id_test_7.jpeg?alt=media&token=58c7738b-0eec-4370-8fc7-9472d51bb0b7",
  // ];

  // bool same_face = await compare_faces(
  //   source_image: image_urls[0],
  //   target_image: image_urls[1],
  //   //target_image: image_urls.last,
  //   similarity_threshold: 80.0,
  //   region: 'us-east-1',
  // );

  // print("Same face: " + same_face.toString());
}
