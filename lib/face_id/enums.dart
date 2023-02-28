enum FaceEthnicity {
  africa,
  asia,
  europe,
  latin_america,
}

extension FaceEthnicityExt on FaceEthnicity {
  static FaceEthnicity get_random_face_ethnicity() {
    var list = List<FaceEthnicity>.from(FaceEthnicity.values)..shuffle();
    return list.take(1).first;
  }
}

enum FaceGender {
  female,
  male,
}

extension FaceGenderExt on FaceGender {
  static FaceGender get_random_face_gender() {
    var list = List<FaceGender>.from(FaceGender.values)..shuffle();
    return list.take(1).first;
  }
}
