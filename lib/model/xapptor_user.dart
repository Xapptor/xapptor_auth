import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_auth/get_over_18_date.dart';
import 'package:xapptor_db/xapptor_db.dart';

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
    this.id,
    this.email,
    Map<dynamic, dynamic> snapshot,
  )   : firstname = snapshot['firstname'],
        lastname = snapshot['lastname'],
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
      'roles': {for (var e in roles) e.organization_id: e.value},
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

Future<XapptorUser> get_xapptor_user({String? id}) async {
  User current_user = FirebaseAuth.instance.currentUser!;

  String user_id = id ?? current_user.uid;
  String user_email = id == null ? current_user.email! : '';

  DocumentSnapshot user_snap = await XapptorDB.instance.collection('users').doc(user_id).get();
  return XapptorUser.from_snapshot(
    user_id,
    user_email,
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
