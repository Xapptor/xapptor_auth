// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/login_and_restore_view/apple_button.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/check_remember_me.dart';
import 'package:xapptor_auth/login_and_restore_view/email_form_section.dart';
import 'package:xapptor_auth/login_and_restore_view/google_button/google_button.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/main_button.dart';
import 'package:xapptor_auth/login_and_restore_view/password_form_section.dart';
import 'package:xapptor_auth/login_and_restore_view/second_button.dart';
import 'package:xapptor_auth/login_and_restore_view/third_button.dart';
import 'package:xapptor_auth/signin_with_google.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

extension StateExtension on LoginAndRestoreViewState {
  Widget quick_login_widgets() {
    int current_phone_code_length =
        current_phone_code.value.name.split(',').first.length + current_phone_code.value.dial_code.length;

    int current_phone_code_flex = 1;

    if (current_phone_code_length > 0 && current_phone_code_length <= 12) {
      current_phone_code_flex = (current_phone_code_length * 1.0).floor();
      //
    } else if (current_phone_code_length > 12 && current_phone_code_length <= 25) {
      current_phone_code_flex = (current_phone_code_length * 0.7).floor();
      //
    } else if (current_phone_code_length >= 26) {
      current_phone_code_flex = (current_phone_code_length * 0.4).floor();
    }

    return Form(
      key: form_key,
      child: Column(
        mainAxisSize: is_quick_login(widget.auth_form_type) ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if ((is_login(widget.auth_form_type) || is_quick_login(widget.auth_form_type)) &&
              widget.phone_signin_text_list != null &&
              (current_login_providers == AvailableLoginProviders.all ||
                  current_login_providers == AvailableLoginProviders.email_and_phone))
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: use_email_signin ? widget.text_color : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          use_email_signin = !use_email_signin;
                          email_input_controller.clear();
                          password_input_controller.clear();
                          check_remember_me();
                          setState(() {});
                        },
                        icon: Icon(
                          FontAwesomeIcons.envelope,
                          color: use_email_signin ? Colors.white : widget.text_color,
                          size: 30,
                        ),
                      ),
                    ),
                    Container(
                      height: 38,
                      width: 38,
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: !use_email_signin ? widget.text_color : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          use_email_signin = !use_email_signin;
                          email_input_controller.clear();
                          password_input_controller.clear();
                          check_remember_me();
                          setState(() {});
                        },
                        icon: Icon(
                          FontAwesomeIcons.commentSms,
                          color: !use_email_signin ? Colors.white : widget.text_color,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: sized_box_space * 0.7,
                ),
              ],
            ),
          email_form_section(current_phone_code_flex),
          password_form_section(),
          if (is_login(widget.auth_form_type))
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                !use_email_signin && !verification_code_sent.value
                    ? const SizedBox()
                    : SizedBox(
                        height: sized_box_space,
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    second_button(),
                    third_button(),
                  ].where((widget) => widget != null).cast<Widget>().toList(),
                ),
              ],
            ),
          SizedBox(
            height: sized_box_space,
          ),
          main_button(),
          SizedBox(
            height: sized_box_space,
          ),
          if (current_login_providers == AvailableLoginProviders.all ||
              current_login_providers == AvailableLoginProviders.apple ||
              current_login_providers == AvailableLoginProviders.google)
            Column(
              children: [
                Text(
                  "Or",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.text_color,
                  ),
                ),
                SizedBox(
                  height: sized_box_space,
                ),
                google_button(
                  on_pressed: () async {
                    // This in only call on Mobile, for Web the button is "renderButton()" and it's rendered from the web SDK

                    GoogleSignInAccount? google_signin_account = await handle_google_signin();
                    if (google_signin_account != null) {
                      signin_with_google(google_signin_account);
                    }
                  },
                ),
                SizedBox(
                  height: sized_box_space,
                ),
                apple_button(),
              ].where((widget) => widget != null).cast<Widget>().toList(),
            ),
        ],
      ),
    );
  }
}
