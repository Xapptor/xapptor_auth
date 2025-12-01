import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/account_view/on_pressed_first_button.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_ui/widgets/card/custom_card.dart';
import 'package:xapptor_ui/utils/is_portrait.dart';

extension StateExtension on AccountViewState {
  Widget main_button() {
    double screen_width = MediaQuery.of(context).size.width;
    bool portrait = is_portrait(context);

    final double buttonWidth = screen_width / (portrait ? 2 : 8);
    const double buttonHeight = 50.0;
    const double borderRadius = 25.0; // Half of height for pill shape

    final String buttonText =
        widget.text_list.get(source_language_index)[is_edit_account(widget.auth_form_type) ? 7 : 7];

    // Use gradient border style when enabled
    if (widget.use_gradient_border_button && widget.form_border_gradient != null) {
      return Container(
        height: buttonHeight,
        width: buttonWidth,
        decoration: BoxDecoration(
          gradient: widget.form_border_gradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          margin: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: widget.form_container_background_color ?? widget.background_color ?? Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius - 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius - 2),
              onTap: on_pressed_first_button,
              splashColor: widget.text_color.withValues(alpha: 0.1),
              highlightColor: widget.text_color.withValues(alpha: 0.05),
              child: Center(
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Default filled gradient style
    return SizedBox(
      height: buttonHeight,
      width: buttonWidth,
      child: CustomCard(
        border_radius: screen_width,
        elevation: (widget.first_button_color.colors.first == Colors.transparent &&
                widget.first_button_color.colors.last == Colors.transparent)
            ? 0
            : 7,
        on_pressed: on_pressed_first_button,
        linear_gradient: widget.first_button_color,
        splash_color: widget.second_button_color.withValues(alpha: 0.2),
        child: Center(
          child: Text(
            buttonText,
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
