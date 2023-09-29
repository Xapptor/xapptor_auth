import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_functions/show_email_verification_alert_dialog.dart';
import 'package:xapptor_logic/show_alert.dart';
import 'package:xapptor_router/app_screens.dart';

extension Login on AuthFormFunctions {
  login({
    required BuildContext context,
    required bool remember_me,
    required GlobalKey<FormState> form_key,
    required List<TextEditingController> input_controllers,
    required SharedPreferences prefs,
    required Persistence persistence,
    required bool verify_email,
  }) async {
    TextEditingController email_input_controller = input_controllers[0];
    TextEditingController password_input_controller = input_controllers[1];

    if (form_key.currentState!.validate()) {
      // Set persistence in Web.
      if (UniversalPlatform.isWeb) {
        await FirebaseAuth.instance.setPersistence(persistence);
      }

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email_input_controller.text,
        password: password_input_controller.text,
      )
          .then((UserCredential value) async {
        User user = value.user!;
        String uid = user.uid;

        DocumentSnapshot snapshot_user =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();

        if (verify_email) {
          if (value.user!.emailVerified) {
            if (remember_me) prefs.setString("email", value.user!.email!);
            email_input_controller.clear();
            password_input_controller.clear();
            open_screen("home");
          } else {
            show_email_verification_alert_dialog(
              context: context,
              user: value.user!,
            );
          }
        } else {
          if (remember_me) prefs.setString("email", value.user!.email!);
          email_input_controller.clear();
          password_input_controller.clear();
          open_screen("home");
        }

        return null;
      }).catchError((error) {
        print("Login error: $error");
        show_error_alert(
          context: context,
          message: 'The password or email are invalid',
        );
      });
    }
  }
}
