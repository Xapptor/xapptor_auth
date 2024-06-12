import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/on_pressed_first_button.dart';
import 'package:xapptor_ui/widgets/card/custom_card.dart';
import 'package:xapptor_ui/utils/is_portrait.dart';

extension StateExtension on LoginAndRestoreViewState {
  Widget main_button() {
    double screen_width = MediaQuery.of(context).size.width;
    bool portrait = is_portrait(context);

    String main_button_text = '';

    if (widget.phone_signin_text_list != null && !use_email_signin) {
      main_button_text =
          widget.phone_signin_text_list!.get(source_language_index)[!verification_code_sent.value ? 2 : 4];
    } else {
      main_button_text = widget.text_list.get(source_language_index)[
          widget.text_list.get(source_language_index).length -
              (is_login(widget.auth_form_type) || is_quick_login(widget.auth_form_type) ? 3 : 1)];
    }

    return SizedBox(
      height: 50,
      width: screen_width / (portrait ? 2 : 8),
      child: CustomCard(
        border_radius: screen_width,
        elevation: (widget.first_button_color.colors.first == Colors.transparent &&
                widget.first_button_color.colors.last == Colors.transparent)
            ? 0
            : 7,
        on_pressed: on_pressed_first_button,
        linear_gradient: widget.first_button_color,
        splash_color: widget.second_button_color.withOpacity(0.2),
        child: Center(
          child: Text(
            main_button_text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: (widget.first_button_color.colors.first == Colors.transparent &&
                      widget.first_button_color.colors.last == Colors.transparent)
                  ? widget.second_button_color
                  : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
