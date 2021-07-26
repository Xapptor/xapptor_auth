import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_auth/generic_user.dart';
import 'open_home.dart';

check_login() async {
  if (FirebaseAuth.instance.currentUser != null) {
    User auth_user = FirebaseAuth.instance.currentUser!;
    print("User is sign");

    String uid = auth_user.uid;
    DocumentSnapshot user =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    GenericUser generic_user = GenericUser(
      uid: uid,
      firstname: user.get("firstname"),
      lastname: user.get("lastname"),
      email: auth_user.email!,
      birthday: user.get("birthday").toString(),
      gender: user.get("gender"),
      country: user.get("country"),
      admin: false,
    );
    open_home(generic_user);
  } else {
    print("User is not sign");
  }
}
