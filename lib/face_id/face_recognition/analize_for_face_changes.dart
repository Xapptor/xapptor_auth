bool analize_for_face_changes(List<double> probability_list) {
  probability_list.sort((a, b) => a.compareTo(b));
  double difference = probability_list.last - probability_list.first;
  return difference > 0.5;
}
