import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<bool> check_user_token({
  required bool renew,
}) async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  try {
    User? current_user = auth.currentUser;

    if (current_user != null) {
      if (renew) {
        await current_user.getIdToken(true);
      }

      debugPrint('Firebase token renewed and saved.');
      return true;
      //
    } else {
      debugPrint('No user is currently signed in.');
      return false;
      //
    }
  } catch (e) {
    debugPrint('Error renewing Firebase token: $e');
    return false;
  }
}
