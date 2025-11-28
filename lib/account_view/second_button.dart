import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/delete_account.dart';
import 'package:xapptor_ui/values/ui.dart';

extension StateExtension on AccountViewState {
  Widget? second_button() {
    double screen_width = MediaQuery.of(context).size.width;

    return is_edit_account(widget.auth_form_type)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: sized_box_space),
              TextButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        screen_width,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  if (widget.second_button_action != null) {
                    widget.second_button_action!();
                  } else {
                    if (is_edit_account(widget.auth_form_type)) {
                      delete_account(
                        context: context,
                        text_list: widget.text_list
                            .get(source_language_index)
                            .sublist(widget.text_list.get(source_language_index).length - 9),
                      );
                    }
                  }
                },
                child: Text(
                  widget.text_list.get(source_language_index)[8],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: is_edit_account(widget.auth_form_type) ? Colors.red : widget.second_button_color,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: sized_box_space),
            ],
          )
        : null;
  }
}
