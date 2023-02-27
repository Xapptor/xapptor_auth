import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xapptor_auth/form_section_container.dart';
import 'package:xapptor_auth/login_and_restore_view.dart';
import 'package:xapptor_auth/show_quick_login.dart';
import 'package:xapptor_ui/values/ui.dart';

extension LinkPhoneButton on AccountViewState {
  Widget link_phone_button(bool phone_linked) {
    return is_edit_account(widget.auth_form_type) && !phone_linked
        ? Column(
            children: [
              SizedBox(
                height: sized_box_space,
              ),
              form_section_container(
                outline_border: widget.outline_border,
                border_color: widget.text_color,
                background_color: widget.text_field_background_color,
                add_final_padding: true,
                child: TextButton(
                  onPressed: () {
                    show_quick_login(
                      context: context,
                      available_login_providers: AvailableLoginProviders.phone,
                      message: 'Link Phone',
                      callback: () {
                        phone_linked = true;
                        setState(() {});
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        FontAwesomeIcons.link,
                        size: 16,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        child: Text(
                          'Link Phone',
                          style: TextStyle(
                            color: widget.text_color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Container();
  }
}
