import 'package:flutter/material.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

extension StateExtension on LoginAndRestoreViewState {
  Widget? third_button() {
    return !use_email_signin
        ? null
        : TextButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            ),
            onPressed: () {
              if (widget.third_button_action != null) {
                widget.third_button_action!();
              }
            },
            child: Text(
              widget.text_list.get(source_language_index)[5],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.third_button_color,
                fontSize: 12,
              ),
            ),
          );
  }
}
