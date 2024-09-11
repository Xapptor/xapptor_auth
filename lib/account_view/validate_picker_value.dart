String validate_picker_value(
  String value,
  List<String> list,
) {
  for (var list_item in list) {
    if (list_item == value) {
      return value;
    }
  }

  return list.firstWhere(
    (element) => element.contains(value),
    orElse: () => list.first,
  );
}
