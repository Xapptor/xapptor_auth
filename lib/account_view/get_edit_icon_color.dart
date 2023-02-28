import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';

extension GetEditIconColor on AccountViewState {
  Color get_edit_icon_color() {
    return widget.edit_icon_use_text_field_background_color != null
        ? widget.edit_icon_use_text_field_background_color!
            ? widget.text_field_background_color != null
                ? widget.text_field_background_color!
                : widget.text_color
            : widget.text_color
        : widget.text_color;
  }
}
