import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_functions/update_user_email.dart';
import 'package:xapptor_auth/auth_form_functions/update_user_name_and_info.dart';
import 'package:xapptor_auth/auth_form_functions/update_user_password.dart';
import 'package:xapptor_auth/show_authentication_alert_dialog.dart';

extension ShowEditAccountAlertDialog on AccountViewState {
  show_edit_account_alert_dialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext dialog_context) {
        return AlertDialog(
          title: const Text("Do you want to save the changes?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Discard"),
              onPressed: () {
                Navigator.of(context).pop();
                editing_email = false;
                editing_password = false;
                editing_name_and_info = false;
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Accept"),
              onPressed: () {
                if (editing_email ||
                    editing_password ||
                    editing_name_and_info) {
                  Navigator.of(dialog_context).pop();
                  show_authentication_alert_dialog(
                    context: context,
                    email: email,
                    text_color: widget.text_color,
                    enabled: password_verification_enabled,
                    callback: () {
                      String uid = FirebaseAuth.instance.currentUser!.uid;

                      if (editing_name_and_info) {
                        List<TextEditingController> inputControllers = [
                          firstname_input_controller,
                          last_name_input_controller,
                        ];

                        AuthFormFunctions().update_user_name_and_info(
                          context: context,
                          scaffold_key: scaffold_key,
                          name_and_info_form_key: user_info_view_form_key,
                          input_controllers: inputControllers,
                          selected_date: selected_date,
                          gender_value: widget.gender_values
                              .get(source_language_index)
                              .indexOf(gender_value),
                          country_value: country_value ?? "",
                          user_id: uid,
                          password_verification_enabled:
                              password_verification_enabled,
                        );
                      }

                      if (editing_password) {
                        List<TextEditingController> inputControllers = [
                          password_input_controller,
                          confirm_password_input_controller,
                        ];

                        AuthFormFunctions().update_user_password(
                          context: context,
                          scaffold_key: scaffold_key,
                          password_form_key: user_info_view_form_key,
                          input_controllers: inputControllers,
                          user_id: uid,
                          email: email_input_controller.text,
                          password_verification_enabled:
                              password_verification_enabled,
                        );
                      }

                      if (editing_email) {
                        List<TextEditingController> inputControllers = [
                          email_input_controller,
                          confirm_email_input_controller,
                        ];

                        AuthFormFunctions().update_user_email(
                          context: context,
                          scaffold_key: scaffold_key,
                          email_form_key: user_info_view_form_key,
                          input_controllers: inputControllers,
                          user_id: uid,
                          password_verification_enabled:
                              password_verification_enabled,
                        );
                      }
                    },
                  );
                }
              },
            )
          ],
        );
      },
    );
  }
}
