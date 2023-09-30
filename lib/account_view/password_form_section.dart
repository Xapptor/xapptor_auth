// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/account_view/fill_fields.dart';
import 'package:xapptor_auth/account_view/get_edit_icon_color.dart';
import 'package:xapptor_auth/account_view/on_pressed_first_button.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/form_section_container.dart';
import 'package:xapptor_logic/form_field_validators.dart';
import 'package:xapptor_ui/values/ui.dart';

extension PasswordFormSection on AccountViewState {
  Widget password_form_section(bool email_linked) {
    return is_edit_account(widget.auth_form_type) && !email_linked && !linking_email
        ? Container()
        : Container(
            margin: EdgeInsets.only(bottom: sized_box_space),
            child: Form(
              key: password_form_key,
              child: form_section_container(
                outline_border: widget.outline_border,
                border_color: widget.text_color,
                background_color: widget.text_field_background_color,
                icon: editing_password ? Icons.delete_outlined : Icons.edit,
                icon_color: get_edit_icon_color(),
                icon_on_press: () {
                  editing_password = !editing_password;
                  if (!editing_password) {
                    fill_fields();
                  } else {
                    password_input_controller.text = "";
                    confirm_password_input_controller.text = "";
                  }
                  setState(() {});
                },
                child: Column(
                  children: [
                    TextFormField(
                      onFieldSubmitted: (value) {
                        on_pressed_first_button();
                      },
                      style: TextStyle(color: widget.text_color),
                      enabled: is_edit_account(widget.auth_form_type) ? editing_password : true,
                      decoration: InputDecoration(
                        labelText: widget.text_list.get(source_language_index)[2],
                        labelStyle: TextStyle(
                          color: widget.text_color,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: widget.text_color,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            password_visible ? Icons.visibility : Icons.visibility_off,
                            color: widget.text_color,
                          ),
                          onPressed: () {
                            setState(() {
                              password_visible = !password_visible;
                            });
                          },
                        ),
                      ),
                      controller: password_input_controller,
                      validator: (value) => FormFieldValidators(
                        value: value!,
                        type: FormFieldValidatorsType.password,
                      ).validate(),
                      obscureText: !password_visible,
                    ),
                    SizedBox(
                      height: sized_box_space,
                    ),
                    TextFormField(
                      style: TextStyle(
                        color: widget.text_color,
                      ),
                      enabled: is_edit_account(widget.auth_form_type) ? editing_password : true,
                      decoration: InputDecoration(
                        labelText: widget.text_list.get(source_language_index)[3],
                        labelStyle: TextStyle(
                          color: widget.text_color,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: widget.text_color,
                          ),
                        ),
                      ),
                      controller: confirm_password_input_controller,
                      validator: (value) => FormFieldValidators(
                        value: value!,
                        type: FormFieldValidatorsType.password,
                      ).validate(),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
