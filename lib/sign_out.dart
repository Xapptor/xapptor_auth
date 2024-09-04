import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

sign_out({
  required BuildContext context,
  Function? callback,
}) async {
  await FirebaseAuth.instance.signOut().then((value) async {
    if (current_login_providers == AvailableLoginProviders.all ||
        current_login_providers == AvailableLoginProviders.google) {
      bool is_signed_in = await google_signin?.isSignedIn() ?? false;

      if (is_signed_in) {
        await google_signin?.signOut();
        debugPrint("User is signed out from Google");
      }
    }

    if (callback != null) {
      callback();
    } else {
      if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    }
  });
}
