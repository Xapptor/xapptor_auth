// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/form_section_container.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/on_pressed_first_button.dart';
import 'package:xapptor_logic/form_field_validators.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:xapptor_ui/widgets/country_picker.dart';

extension StateExtension on LoginAndRestoreViewState {
  Widget email_form_section(int current_phone_code_flex) {
    return form_section_container(
      outline_border: widget.outline_border,
      border_color: widget.text_color,
      background_color: widget.text_field_background_color,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!use_email_signin)
                Expanded(
                  flex: current_phone_code_flex,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: CountryPicker(
                      current_phone_code: current_phone_code,
                      text_color: widget.text_color,
                      setState: setState,
                      country_picker_type: CountryPickerType.phone,
                    ),
                  ),
                ),
              if (!use_email_signin) const Spacer(flex: 1),
              Expanded(
                flex: 12,
                child: TextFormField(
                  onFieldSubmitted: (value) {
                    on_pressed_first_button();
                  },
                  style: TextStyle(color: widget.text_color),
                  decoration: InputDecoration(
                    labelText: widget.phone_signin_text_list != null && !use_email_signin
                        ? widget.phone_signin_text_list!.get(source_language_index)[0]
                        : widget.text_list.get(source_language_index)[
                            is_login(widget.auth_form_type) || is_quick_login(widget.auth_form_type) ? 0 : 1],
                    labelStyle: TextStyle(
                      color: widget.text_color,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.text_color,
                      ),
                    ),
                    errorMaxLines: 2,
                  ),
                  controller: email_input_controller,
                  inputFormatters: use_email_signin ? null : [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => FormFieldValidators(
                    value: value!,
                    type: use_email_signin ? FormFieldValidatorsType.email : FormFieldValidatorsType.phone,
                  ).validate(),
                  keyboardType: use_email_signin ? TextInputType.emailAddress : TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(
            height: sized_box_space,
          ),
        ],
      ),
    );
  }
}
