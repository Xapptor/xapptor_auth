import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_logic/timestamp_to_date.dart';

class XapptorUser {
  String id;
  String firstname;
  String lastname;
  String email;
  String birthday;
  int gender;
  String country;
  bool admin;
  bool owner;

  XapptorUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.birthday,
    required this.gender,
    required this.country,
    required this.admin,
    required this.owner,
  });

  XapptorUser.from_snapshot(
    String id,
    String email,
    Map<dynamic, dynamic> snapshot,
  )   : id = id,
        firstname = snapshot['firstname'],
        lastname = snapshot['lastname'],
        email = email,
        birthday = timestamp_to_date(snapshot['birthday']),
        gender = snapshot['gender'],
        country = snapshot['country'],
        admin = snapshot['admin'] ?? false,
        owner = snapshot['owner'] ?? false;

  Map<String, dynamic> to_json() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'birthday': birthday,
      'gender': gender,
      'country': country,
      'admin': admin,
      'owner': owner,
    };
  }

  factory XapptorUser.empty() {
    return XapptorUser(
      id: '',
      firstname: '',
      lastname: '',
      email: '',
      birthday: '',
      gender: 0,
      country: '',
      admin: false,
      owner: false,
    );
  }
}

Future<XapptorUser> get_xapptor_user() async {
  User current_user = await FirebaseAuth.instance.currentUser!;

  DocumentSnapshot user_snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(current_user.uid)
      .get();
  return XapptorUser.from_snapshot(
    current_user.uid,
    current_user.email!,
    user_snap.data() as Map<String, dynamic>,
  );
}
