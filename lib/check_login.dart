import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_auth/xapptor_user.dart';
import 'open_home.dart';

check_login() async {
  if (FirebaseAuth.instance.currentUser != null) {
    User auth_user = FirebaseAuth.instance.currentUser!;
    print("User is logged in");
    String uid = auth_user.uid;

    DocumentSnapshot snapshot_user =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    XapptorUser xapptor_user = XapptorUser.from_snapshot(
      uid,
      snapshot_user.data() as Map<String, dynamic>,
    );
    open_home(xapptor_user);
  } else {
    print("User is not sign");
  }
}
