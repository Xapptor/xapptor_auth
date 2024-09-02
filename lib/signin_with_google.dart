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
  await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
    await XapptorDB.instance.collection("users").doc(value.user!.uid).set(
      {},
      SetOptions(
        merge: true,
      ),
    ).then((value) {
      open_screen("home");
    });
  });
}
