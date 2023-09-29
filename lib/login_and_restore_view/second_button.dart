import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/send_verification_code.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

extension SecondButton on LoginAndRestoreViewState {
  Widget second_button() {
    return !use_email_signin && !verification_code_sent.value
        ? Container()
        : TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            ),
            onPressed: () {
              if (use_email_signin) {
                if (widget.second_button_action != null) {
                  widget.second_button_action!();
                }
              } else {
                if (widget.resend_code_button_action != null) {
                  widget.resend_code_button_action!();
                } else {
                  auth_form_functions.send_verification_code(
                    context: context,
                    phone_input_controller: TextEditingController(
                      text: '${current_phone_code.value.dial_code} ${email_input_controller.text}',
                    ),
                    code_input_controller: password_input_controller,
                    prefs: prefs,
                    update_verification_code_sent:
                        update_verification_code_sent,
                    remember_me: remember_me,
                    callback: null,
                  );
                }
              }
            },
            child: Text(
              !use_email_signin && widget.phone_signin_text_list != null
                  ? widget.phone_signin_text_list!.get(source_language_index)[
                      widget.phone_signin_text_list!
                              .get(source_language_index)
                              .length -
                          2]
                  : widget.text_list.get(source_language_index)[
                      widget.text_list.get(source_language_index).length - 2],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.second_button_color,
                fontSize: 12,
              ),
            ),
          );
  }
}
