// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xapptor_auth/form_section_container.dart';
import 'package:xapptor_ui/values/ui.dart';

extension LinkEmailButton on AccountViewState {
  Widget link_email_button(bool email_linked) {
    return is_edit_account(widget.auth_form_type) && !email_linked && !linking_email
        ? Container(
            margin: EdgeInsets.only(bottom: sized_box_space),
            child: form_section_container(
              outline_border: widget.outline_border,
              border_color: widget.text_color,
              background_color: widget.text_field_background_color,
              add_final_padding: true,
              child: TextButton(
                onPressed: () {
                  editing_email = true;
                  editing_password = true;
                  password_input_controller.text = "";
                  confirm_password_input_controller.text = "";

                  linking_email = true;
                  setState(() {});
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      FontAwesomeIcons.link,
                      size: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Link Email',
                        style: TextStyle(
                          color: widget.text_color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }
}
