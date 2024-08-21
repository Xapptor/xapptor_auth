// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_ui/utils/show_alert.dart';
import 'package:xapptor_router/app_screens.dart';

extension RestorePassword on AuthFormFunctions {
  restore_password({
    required BuildContext context,
    required GlobalKey<FormState> form_key,
    required TextEditingController email_input_controller,
  }) async {
    if (form_key.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email_input_controller.text).then((value) {
          show_success_alert(
            context: context,
            message: 'Restore password email sent successfully',
          );
          open_screen("login");
        });
      } catch (error) {
        debugPrint("An error occured while trying to send password reset email");
        debugPrint(error.toString());
      }
    }
  }
}
