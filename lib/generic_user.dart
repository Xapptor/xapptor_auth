class GenericUser {
  String uid;
  String firstname;
  String lastname;
  String email;
  String birthday;
  String gender;
  String country;
  bool admin;

  GenericUser({
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.birthday,
    required this.gender,
    required this.country,
    required this.admin,
  });
}
