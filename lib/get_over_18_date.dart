DateTime get_over_18_date() {
  DateTime over_18 = DateTime(
    DateTime.now().year - 18,
    DateTime.now().month,
    DateTime.now().day,
  );
  return over_18;
}
