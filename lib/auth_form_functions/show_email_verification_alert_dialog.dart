import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';

extension ShowEmailVerificationAlertDialog on AuthFormFunctions {
  show_email_verification_alert_dialog({
    required BuildContext context,
    required User user,
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("You haven't verified your email yet"),
          content: const Text("Would you like to send an email verification?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Accept"),
              onPressed: () async {
                await user.sendEmailVerification().then((value) {
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
