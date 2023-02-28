import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_auth/get_over_18_date.dart';

class XapptorUser {
  String id;
  String firstname;
  String lastname;
  String email;
  DateTime birthday;
  int gender;
  String country;
  bool admin;
  bool owner;
  List<Role> roles;

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
    required this.roles,
  });

  XapptorUser.from_snapshot(
    String id,
    String email,
    Map<dynamic, dynamic> snapshot,
  )   : id = id,
        firstname = snapshot['firstname'],
        lastname = snapshot['lastname'],
        email = email,
        birthday = (snapshot['birthday'] as Timestamp).toDate(),
        gender = snapshot['gender'],
        country = snapshot['country'],
        admin = snapshot['admin'] ?? false,
        owner = snapshot['owner'] ?? false,
        roles = snapshot['roles'] == null
            ? []
            : (snapshot['roles'] as Map<String, dynamic>)
                .entries
                .map(
                  (e) => Role(
                    organization_id: e.key,
                    value: e.value,
                  ),
                )
                .toList();

  Map<String, dynamic> to_json() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'birthday': birthday,
      'gender': gender,
      'country': country,
      'admin': admin,
      'owner': owner,
      'roles': Map.fromIterable(
        roles,
        key: (e) => e.organization_id,
        value: (e) => e.value,
      ),
    };
  }

  factory XapptorUser.empty() {
    return XapptorUser(
      id: '',
      firstname: '',
      lastname: '',
      email: '',
      birthday: get_over_18_date(),
      gender: 0,
      country: '',
      admin: false,
      owner: false,
      roles: [],
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

class Role {
  String organization_id;
  String value;

  Role({
    required this.organization_id,
    required this.value,
  });
}
