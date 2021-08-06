import 'package:xapptor_logic/timestamp_to_date.dart';

class XapptorUser {
  String id;
  String firstname;
  String lastname;
  String email;
  String birthday;
  String gender;
  String country;
  bool admin;

  XapptorUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.birthday,
    required this.gender,
    required this.country,
    required this.admin,
  });

  XapptorUser.from_snapshot(String id, Map<String, dynamic> snapshot)
      : id = id,
        firstname = snapshot['firstname'],
        lastname = snapshot['lastname'],
        email = snapshot['email'],
        birthday = timestamp_to_date(snapshot['birthday']),
        gender = snapshot['gender'],
        country = snapshot['country'],
        admin = snapshot['admin'];

  Map<String, dynamic> to_json() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'birthday': birthday,
      'gender': gender,
      'country': country,
      'admin': admin,
    };
  }
}
