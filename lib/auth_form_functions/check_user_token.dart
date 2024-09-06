import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<bool> check_user_token({
  required bool renew,
}) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FlutterSecureStorage storage = const FlutterSecureStorage();

  try {
    User? current_user = auth.currentUser;

    if (current_user != null) {
      if (renew) {
        String? new_token = await current_user.getIdToken(true);

        await storage.write(
          key: 'firebase_token',
          value: new_token,
        );
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
