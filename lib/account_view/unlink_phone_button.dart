// ignore_for_file: invalid_use_of_protected_member

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xapptor_auth/form_section_container.dart';
import 'package:xapptor_auth/unlink_alert.dart';
import 'package:xapptor_logic/show_alert.dart';
import 'package:xapptor_ui/values/ui.dart';

extension UnlinkPhoneButton on AccountViewState {
  Widget unlink_phone_button(bool phone_linked, List<UserInfo> user_providers) {
    return is_edit_account(widget.auth_form_type) && phone_linked && user_providers.length > 1
        ? Container(
            margin: EdgeInsets.only(bottom: sized_box_space),
            child: form_section_container(
              outline_border: widget.outline_border,
              border_color: widget.text_color,
              background_color: widget.text_field_background_color,
              add_final_padding: true,
              child: TextButton(
                onPressed: () async {
                  unlink_alert(
                    context: context,
                    text_list: widget.text_list.get(source_language_index),
                    auth_provider_name: 'phone',
                    callback: () async {
                      await FirebaseAuth.instance.currentUser?.unlink(PhoneAuthProvider().providerId).then((value) {
                        setState(() {});
                        show_success_alert(
                          context: context,
                          message: 'Phone unlink success',
                        );
                      }).onError((error, stackTrace) {
                        debugPrint(error.toString());
                        show_error_alert(
                          context: context,
                          message: 'Phone unlink error',
                        );
                      });
                    },
                  );
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
                      FontAwesomeIcons.linkSlash,
                      size: 16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Unlink Phone',
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
