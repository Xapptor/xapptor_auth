// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/account_view/fill_fields.dart';
import 'package:xapptor_auth/account_view/get_edit_icon_color.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/form_section_container.dart';
import 'package:xapptor_logic/form_field_validators.dart';
import 'package:xapptor_ui/values/ui.dart';

extension StateExtension on AccountViewState {
  Widget? email_form_section(bool email_linked) {
    return is_edit_account(widget.auth_form_type) && !email_linked && !linking_email
        ? null
        : Container(
            margin: EdgeInsets.only(bottom: sized_box_space),
            child: Form(
              key: email_form_key,
              child: form_section_container(
                outline_border: widget.outline_border,
                border_color: widget.text_color,
                background_color: widget.text_field_background_color,
                icon: editing_email ? Icons.delete_outlined : Icons.edit,
                icon_color: get_edit_icon_color(),
                icon_on_press: () {
                  editing_email = !editing_email;
                  if (!editing_email) {
                    fill_fields();
                  }
                  setState(() {});
                },
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(color: widget.text_color),
                      enabled: is_edit_account(widget.auth_form_type) ? editing_email : true,
                      decoration: InputDecoration(
                        labelText: widget.text_list.get(source_language_index)[0],
                        labelStyle: TextStyle(
                          color: widget.text_color,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: widget.text_color,
                          ),
                        ),
                      ),
                      controller: email_input_controller,
                      validator: (value) => FormFieldValidators(
                        value: value!,
                        type: FormFieldValidatorsType.email,
                      ).validate(),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: sized_box_space,
                    ),
                    if (is_register(widget.auth_form_type) || is_edit_account(widget.auth_form_type))
                      TextFormField(
                        style: TextStyle(color: widget.text_color),
                        enabled: is_edit_account(
                          widget.auth_form_type,
                        )
                            ? editing_email
                            : true,
                        decoration: InputDecoration(
                          labelText: widget.text_list.get(source_language_index)[1],
                          labelStyle: TextStyle(
                            color: widget.text_color,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.text_color,
                            ),
                          ),
                        ),
                        controller: confirm_email_input_controller,
                        validator: (value) => FormFieldValidators(
                          value: value!,
                          type: FormFieldValidatorsType.email,
                        ).validate(),
                        keyboardType: TextInputType.emailAddress,
                      ),
                  ],
                ),
              ),
            ),
          );
  }
}
