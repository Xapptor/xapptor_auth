// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/account_view/fill_fields.dart';
import 'package:xapptor_auth/account_view/get_edit_icon_color.dart';
import 'package:xapptor_auth/account_view/select_date.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/form_section_container.dart';
import 'package:xapptor_logic/form_field_validators.dart';
import 'package:xapptor_ui/values/ui.dart';

extension StateExtension on AccountViewState {
  Widget user_info_form_section() {
    double screen_width = MediaQuery.of(context).size.width;

    Color dropdown_color = widget.text_color == Colors.white ? widget.text_field_background_color! : Colors.white;

    return Container(
      margin: EdgeInsets.only(bottom: sized_box_space),
      child: Form(
        key: name_and_info_form_key,
        child: form_section_container(
          outline_border: widget.outline_border,
          border_color: widget.text_color,
          background_color: widget.text_field_background_color,
          icon: editing_name_and_info ? Icons.delete_outlined : Icons.edit,
          icon_color: get_edit_icon_color(),
          icon_on_press: () {
            editing_name_and_info = !editing_name_and_info;
            if (!editing_name_and_info) {
              fill_fields();
            }
            setState(() {});
          },
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(color: widget.text_color),
                enabled: is_edit_account(widget.auth_form_type) ? editing_name_and_info : true,
                decoration: InputDecoration(
                  labelText: widget.text_list.get(source_language_index)[4],
                  labelStyle: TextStyle(
                    color: widget.text_color,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.text_color,
                    ),
                  ),
                ),
                controller: firstname_input_controller,
                validator: (value) => FormFieldValidators(
                  value: value!,
                  type: FormFieldValidatorsType.name,
                ).validate(),
              ),
              SizedBox(
                height: sized_box_space,
              ),
              TextFormField(
                style: TextStyle(color: widget.text_color),
                enabled: is_edit_account(widget.auth_form_type) ? editing_name_and_info : true,
                decoration: InputDecoration(
                  labelText: widget.text_list.get(source_language_index)[5],
                  labelStyle: TextStyle(
                    color: widget.text_color,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.text_color,
                    ),
                  ),
                ),
                controller: last_name_input_controller,
                validator: (value) => FormFieldValidators(
                  value: value!,
                  type: FormFieldValidatorsType.name,
                ).validate(),
              ),
              SizedBox(
                height: sized_box_space,
              ),
              SizedBox(
                width: screen_width,
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all<double>(
                      0,
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.transparent,
                    ),
                    overlayColor: MaterialStateProperty.all<Color>(
                      Colors.grey.withOpacity(0.2),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width,
                        ),
                        side: BorderSide(
                          color: widget.text_color,
                        ),
                      ),
                    ),
                  ),
                  onPressed: is_edit_account(widget.auth_form_type) && !editing_name_and_info
                      ? null
                      : () {
                          select_date();
                        },
                  child: Text(
                    birthday_label != "" ? birthday_label : widget.text_list.get(source_language_index)[6],
                    style: TextStyle(
                      color: widget.text_color,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: sized_box_space,
              ),
              DropdownButton<String>(
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: widget.text_color,
                ),
                isExpanded: true,
                value: gender_value == "" ? widget.gender_values.get(source_language_index)[0] : gender_value,
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                  color: widget.text_color,
                ),
                underline: Container(
                  height: 1,
                  color: widget.text_color,
                ),
                dropdownColor: dropdown_color,
                onChanged: is_edit_account(widget.auth_form_type) && !editing_name_and_info
                    ? null
                    : (new_value) {
                        if (is_edit_account(widget.auth_form_type)) {
                          if (editing_name_and_info) {
                            setState(() {
                              gender_value = new_value!;
                            });
                          }
                        } else {
                          setState(() {
                            gender_value = new_value!;
                          });
                        }
                      },
                items: widget.gender_values.get(source_language_index).map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(
                height: sized_box_space,
              ),
              widget.country_values != null
                  ? DropdownButton<String>(
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: widget.text_color,
                      ),
                      isExpanded: true,
                      value: country_value == "" ? widget.country_values![0] : country_value,
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(
                        color: widget.text_color,
                      ),
                      underline: Container(
                        height: 1,
                        color: widget.text_color,
                      ),
                      dropdownColor: dropdown_color,
                      onChanged: is_edit_account(widget.auth_form_type) && !editing_name_and_info
                          ? null
                          : (new_value) {
                              if (is_edit_account(widget.auth_form_type)) {
                                if (editing_name_and_info) {
                                  setState(() {
                                    country_value = new_value!;
                                  });
                                }
                              } else {
                                setState(() {
                                  country_value = new_value!;
                                });
                              }
                            },
                      items: widget.country_values!.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  : Container(),
              is_register(widget.auth_form_type)
                  ? Column(
                      children: [
                        SizedBox(
                          height: sized_box_space,
                        ),
                        TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            accept_terms = !accept_terms;
                            setState(() {});
                          },
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Icon(
                                  accept_terms ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                                  color: widget.text_color,
                                ),
                              ),
                              const Spacer(flex: 1),
                              Expanded(
                                flex: 12,
                                child: widget.tc_and_pp_text,
                              ),
                              const Spacer(flex: 1),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: sized_box_space,
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
