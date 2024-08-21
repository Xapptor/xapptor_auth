// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_functions/show_user_info_saved_message.dart';
import 'package:xapptor_ui/utils/show_alert.dart';

extension UpdateUserPassword on AuthFormFunctions {
  Future update_user_password({
    required BuildContext context,
    required GlobalKey<ScaffoldState> scaffold_key,
    required GlobalKey<FormState> password_form_key,
    required List<TextEditingController> input_controllers,
    required String user_id,
    required String email,
    required bool password_verification_enabled,
  }) async {
    TextEditingController password_input_controller = input_controllers[0];
    TextEditingController confirm_password_input_controller = input_controllers[1];

    if (password_form_key.currentState!.validate()) {
      if (password_input_controller.text == confirm_password_input_controller.text) {
        User user = FirebaseAuth.instance.currentUser!;

        user.updatePassword(password_input_controller.text).then((_) {
          show_user_info_saved_message(context);
        }).catchError((error) {
          debugPrint("Password can't be changed $error");
        });
      } else {
        show_neutral_alert(
          context: context,
          message: 'The passwords do not match',
        );
      }
    }
  }
}
