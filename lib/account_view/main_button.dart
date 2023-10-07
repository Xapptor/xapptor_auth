import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/account_view/on_pressed_first_button.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_ui/widgets/custom_card.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

extension StateExtension on AccountViewState {
  Widget main_button() {
    double screen_width = MediaQuery.of(context).size.width;
    bool portrait = is_portrait(context);

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
            widget.text_list.get(source_language_index)[is_edit_account(widget.auth_form_type) ? 7 : 7],
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
