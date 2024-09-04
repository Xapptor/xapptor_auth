import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

sign_out({
  required BuildContext context,
  Function? callback,
}) async {
  await FirebaseAuth.instance.signOut().then((value) async {
    if (current_login_providers == AvailableLoginProviders.all ||
        current_login_providers == AvailableLoginProviders.google) {
      GoogleSignIn google_signin = GoogleSignIn();

      if (google_signin.clientId != null) {
        await google_signin.signOut();
      }
    }

    if (callback != null) {
      callback();
    } else {
      if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    }
  });
}
