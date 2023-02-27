import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/account_view/show_edit_account_alert_dialog.dart';
import 'package:xapptor_auth/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/login_and_restore_view.dart';
import 'package:xapptor_auth/show_quick_login.dart';
import 'package:xapptor_logic/show_alert.dart';

extension OnPressedFirstButton on AccountViewState {
  on_pressed_first_button() async {
    if (widget.first_button_action == null) {
      if (is_edit_account(widget.auth_form_type)) {
        if (linking_email) {
          if (email_input_controller.text ==
              confirm_email_input_controller.text) {
            if (password_input_controller.text ==
                confirm_password_input_controller.text) {
              final credential = EmailAuthProvider.credential(
                email: email_input_controller.text,
                password: password_input_controller.text,
              );

              await FirebaseAuth.instance.currentUser
                  ?.linkWithCredential(credential)
                  .then((value) {
                show_success_alert(
                  context: context,
                  message: 'Email linked successfully',
                );
                editing_email = false;
                editing_password = false;
                setState(() {});
              }).onError((error, stackTrace) {
                print(error.toString());

                if (error
                    .toString()
                    .contains('requires recent authentication')) {
                  show_quick_login(
                    context: context,
                    available_login_providers: AvailableLoginProviders.phone,
                  );
                } else {
                  show_error_alert(
                    context: context,
                    message: 'Error linking email',
                  );
                }
              });
            } else {
              show_neutral_alert(
                context: context,
                message: 'The passwords do not match',
              );
            }
          } else {
            show_neutral_alert(
              context: context,
              message: 'The emails do not match',
            );
          }
        } else {
          if (editing_email) {
            if (email_form_key.currentState!.validate()) {
              show_edit_account_alert_dialog(context);
            }
          } else if (editing_password) {
            if (password_form_key.currentState!.validate()) {
              show_edit_account_alert_dialog(context);
            }
          } else if (editing_name_and_info) {
            if (name_and_info_form_key.currentState!.validate()) {
              show_edit_account_alert_dialog(context);
            }
          }
        }
      } else if (is_register(widget.auth_form_type)) {
        List<TextEditingController> inputControllers = [
          firstname_input_controller,
          last_name_input_controller,
          email_input_controller,
          confirm_email_input_controller,
          password_input_controller,
          confirm_password_input_controller,
        ];

        AuthFormFunctions().register(
          context: context,
          accept_terms: accept_terms,
          register_form_key: user_info_view_form_key,
          input_controllers: inputControllers,
          selected_date: selected_date,
          gender_value: widget.gender_values
              .get(source_language_index)
              .indexOf(gender_value),
          country_value: country_value ?? "",
          birthday_label: birthday_label,
        );
      }
    } else {
      widget.first_button_action!();
    }
  }
}
