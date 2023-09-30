// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/form_section_container.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/on_pressed_first_button.dart';
import 'package:xapptor_logic/form_field_validators.dart';
import 'package:xapptor_ui/values/ui.dart';

extension PasswordFormSection on LoginAndRestoreViewState {
  Widget password_form_section() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      child: (!is_login(widget.auth_form_type) && !is_quick_login(widget.auth_form_type)) ||
              (widget.phone_signin_text_list != null && !use_email_signin && !verification_code_sent.value)
          ? Container(
              key: const ValueKey<int>(1),
            )
          : Container(
              key: const ValueKey<int>(0),
              child: Column(
                children: [
                  SizedBox(
                    height: sized_box_space,
                  ),
                  form_section_container(
                    outline_border: widget.outline_border,
                    border_color: widget.text_color,
                    background_color: widget.text_field_background_color,
                    child: Column(
                      children: [
                        TextFormField(
                          onFieldSubmitted: (value) {
                            on_pressed_first_button();
                          },
                          style: TextStyle(color: widget.text_color),
                          decoration: InputDecoration(
                            labelText: widget.phone_signin_text_list != null && !use_email_signin
                                ? widget.phone_signin_text_list!.get(source_language_index)[1]
                                : widget.text_list.get(source_language_index)[1],
                            labelStyle: TextStyle(
                              color: widget.text_color,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.text_color,
                              ),
                            ),
                            suffixIcon: use_email_signin
                                ? IconButton(
                                    icon: Icon(
                                      password_visible ? Icons.visibility : Icons.visibility_off,
                                      color: widget.text_color,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        password_visible = !password_visible;
                                      });
                                    },
                                  )
                                : null,
                          ),
                          controller: password_input_controller,
                          validator: (value) => FormFieldValidators(
                            value: value!,
                            type:
                                use_email_signin ? FormFieldValidatorsType.password : FormFieldValidatorsType.sms_code,
                          ).validate(),
                          obscureText: use_email_signin && !password_visible,
                          keyboardType: use_email_signin ? TextInputType.text : TextInputType.number,
                          inputFormatters: use_email_signin
                              ? null
                              : <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                        ),
                        SizedBox(
                          height: sized_box_space,
                        ),
                        TextButton(
                          onPressed: () {
                            remember_me = !remember_me;
                            setState(() {});
                          },
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 10,
                                ),
                                child: Icon(
                                  remember_me ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: widget.text_color,
                                ),
                              ),
                              Text(
                                widget.text_list.get(source_language_index)[2],
                                style: TextStyle(
                                  color: widget.text_color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
