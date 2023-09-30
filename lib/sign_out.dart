import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

sign_out({
  required BuildContext context,
  Function? callback,
}) async {
  await FirebaseAuth.instance.signOut().then((value) async {
    GoogleSignIn google_signin = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    if (google_signin.clientId != null) {
      await google_signin.signOut();
    }

    if (callback != null) {
      callback();
    } else {
      Navigator.of(context).popUntil((route) {
        return route.isFirst;
      });
    }
  });
}
