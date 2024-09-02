import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_db/xapptor_db.dart';

signin_with_apple(
  AuthorizationCredentialAppleID authorization_credential,
  String raw_nonce,
) async {
  final AuthCredential credential = OAuthProvider("apple.com").credential(
    idToken: authorization_credential.identityToken,
    //rawNonce: raw_nonce,
  );
  await FirebaseAuth.instance.signInWithCredential(credential).then(
    (value) async {
      await XapptorDB.instance.collection("users").doc(value.user!.uid).set(
        {},
        SetOptions(
          merge: true,
        ),
      ).then((value) {
        open_screen("home");
      });
    },
  );
}
