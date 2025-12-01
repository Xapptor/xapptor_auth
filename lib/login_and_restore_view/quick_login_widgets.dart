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
  /// Wraps a social button with a gradient border container if gradient is provided.
  Widget? _wrap_social_button(Widget? child) {
    if (child == null) return null;
    if (widget.social_button_border_gradient == null) return child;

    return Container(
      decoration: BoxDecoration(
        gradient: widget.social_button_border_gradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: widget.form_container_background_color ?? widget.text_field_background_color ?? Colors.transparent,
          borderRadius: BorderRadius.circular(22.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.5),
          child: child,
        ),
      ),
    );
  }

  /// Creates a toggle button for email/phone selection with gradient styling.
  Widget _build_toggle_button({
    required bool isSelected,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    const double buttonSize = 44.0;
    const double borderRadius = 12.0;
    const double iconSize = 22.0;

    // Use gradient style when toggle_button_gradient is provided
    if (widget.toggle_button_gradient != null) {
      if (isSelected) {
        // Selected: filled gradient background
        return Container(
          height: buttonSize,
          width: buttonSize,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: widget.toggle_button_gradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: onPressed,
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),
        );
      } else {
        // Unselected: gradient border with transparent/charcoal fill
        return Container(
          height: buttonSize,
          width: buttonSize,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: widget.toggle_button_gradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: widget.toggle_button_background_color ??
                  widget.form_container_background_color ??
                  Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius - 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius - 1.5),
                onTap: onPressed,
                child: Center(
                  child: Icon(
                    icon,
                    color: widget.text_color,
                    size: iconSize,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    // Default style (original behavior)
    return Container(
      height: 38,
      width: 38,
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isSelected ? widget.text_color : Colors.white,
        borderRadius: BorderRadius.circular(outline_border_radius),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isSelected ? Colors.white : widget.text_color,
          size: 30,
        ),
      ),
    );
  }

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
                    _build_toggle_button(
                      isSelected: use_email_signin,
                      icon: FontAwesomeIcons.envelope,
                      onPressed: () {
                        use_email_signin = !use_email_signin;
                        email_input_controller.clear();
                        password_input_controller.clear();
                        check_remember_me();
                        setState(() {});
                      },
                    ),
                    _build_toggle_button(
                      isSelected: !use_email_signin,
                      icon: FontAwesomeIcons.commentSms,
                      onPressed: () {
                        use_email_signin = !use_email_signin;
                        email_input_controller.clear();
                        password_input_controller.clear();
                        check_remember_me();
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: sized_box_space * 0.7),
              ],
            ),
          email_form_section(current_phone_code_flex),
          password_form_section(),
          if (is_login(widget.auth_form_type))
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (use_email_signin || verification_code_sent.value) const SizedBox(height: sized_box_space),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    second_button(),
                    third_button(),
                  ].where((widget) => widget != null).cast<Widget>().toList(),
                ),
              ],
            ),
          const SizedBox(height: sized_box_space),
          main_button(),
          const SizedBox(height: sized_box_space),
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
                const SizedBox(height: sized_box_space),
                _wrap_social_button(
                  google_button(
                    on_pressed: () async {
                      // This in only call on Mobile, for Web the button is "renderButton()" and it's rendered from the web SDK

                      GoogleSignInAccount? google_signin_account = await handle_google_signin();
                      if (google_signin_account != null) {
                        signin_with_google(google_signin_account);
                      }
                    },
                  ),
                ),
                const SizedBox(height: sized_box_space),
                _wrap_social_button(apple_button()),
              ].where((widget) => widget != null).cast<Widget>().toList(),
            ),
        ],
      ),
    );
  }
}
