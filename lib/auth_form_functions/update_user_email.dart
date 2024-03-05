import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_functions/show_user_info_saved_message.dart';
import 'package:xapptor_ui/utils/show_alert.dart';

extension UpdateUserEmail on AuthFormFunctions {
  update_user_email({
    required BuildContext context,
    required GlobalKey<ScaffoldState> scaffold_key,
    required GlobalKey<FormState> email_form_key,
    required List<TextEditingController> input_controllers,
    required String user_id,
    required bool password_verification_enabled,
  }) async {
    TextEditingController email_input_controller = input_controllers[0];
    TextEditingController confirm_email_input_controller = input_controllers[1];

    if (email_form_key.currentState!.validate()) {
      if (email_input_controller.text == confirm_email_input_controller.text) {
        User user = FirebaseAuth.instance.currentUser!;

        user.verifyBeforeUpdateEmail(email_input_controller.text).then((result) async {
          try {
            await user.sendEmailVerification();
          } catch (error) {
            debugPrint("An error occured while trying to send email verification");
            debugPrint(error.toString());
          }
          if (context.mounted) show_user_info_saved_message(context);
        }).catchError((err) {
          debugPrint(err);
        });
      } else {
        show_neutral_alert(
          context: context,
          message: 'The emails do not match',
        );
      }
    }
  }
}
