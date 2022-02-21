import 'package:xapptor_auth/enums.dart';

String get_random_demo_face_path() {
  String random_face_ethnicity =
      FaceEthnicityExt.get_random_face_ethnicity().name.toLowerCase();

  String random_face_gender =
      FaceGenderExt.get_random_face_gender().name.toLowerCase();

  String demo_face_path =
      "assets/images/face_demos/${random_face_ethnicity}/${random_face_gender}.jpg";

  return demo_face_path;
}
