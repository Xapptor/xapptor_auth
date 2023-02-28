import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/login.dart';
import 'package:xapptor_auth/auth_form_functions/login_phone_number.dart';
import 'package:xapptor_auth/auth_form_functions/restore_password.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

extension OnPressedFirstButton on LoginAndRestoreViewState {
  on_pressed_first_button() {
    if (widget.first_button_action == null) {
      if (is_login(widget.auth_form_type) ||
          is_quick_login(widget.auth_form_type)) {
        if (use_email_signin) {
          List<TextEditingController> inputControllers = [
            email_input_controller,
            password_input_controller,
          ];

          auth_form_functions.login(
            context: context,
            remember_me: remember_me,
            form_key: form_key,
            input_controllers: inputControllers,
            prefs: prefs,
            persistence: Persistence.LOCAL,
            verify_email: widget.verify_email,
          );
        } else {
          TextEditingController phone_input_controller = TextEditingController(
            text: current_phone_code.value.dial_code +
                ' ' +
                email_input_controller.text,
          );

          List<TextEditingController> input_controllers = [
            phone_input_controller,
            password_input_controller,
          ];

          if (form_key.currentState!.validate()) {
            auth_form_functions.login_phone_number(
              context: context,
              input_controllers: input_controllers,
              prefs: prefs,
              verification_code_sent: verification_code_sent,
              update_verification_code_sent: update_verification_code_sent,
              persistence: Persistence.LOCAL,
              remember_me: remember_me,
              callback: widget.quick_login_callback,
            );
          }
        }
      } else {
        auth_form_functions.restore_password(
          context: context,
          form_key: form_key,
          email_input_controller: email_input_controller,
        );
      }
    } else {
      widget.first_button_action!();
    }
  }
}
