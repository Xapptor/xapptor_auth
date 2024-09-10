import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_db/xapptor_db.dart';

signin_with_google(
  GoogleSignInAccount google_signin_account,
) async {
  final GoogleSignInAuthentication google_signin_authentication = await google_signin_account.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: google_signin_authentication.accessToken,
    idToken: google_signin_authentication.idToken,
  );

  String firstname = "";
  String lastname = "";

  if (google_signin_account.displayName != null) {
    List<String> names = [];

    if ((google_signin_account.displayName ?? "").contains(" ")) {
      names = google_signin_account.displayName!.split(" ");
    } else {
      names = [google_signin_account.displayName ?? ""];
    }

    if (names.length == 1) {
      firstname = names[0];
    } else {
      for (int i = 0; i < names.length; i++) {
        if (i < (names.length / 2).floor()) {
          firstname += "${names[i]} ";
        } else {
          lastname += "${names[i]} ";
        }
      }
    }
  }

  await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
    await XapptorDB.instance.collection("users").doc(value.user!.uid).set(
      {
        "email": google_signin_account.email,
        "firstname": firstname,
        "lastname": lastname,
      },
      SetOptions(
        merge: true,
      ),
    ).then((value) {
      open_screen("home");
    });
  });
}
