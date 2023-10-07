// ignore_for_file: invalid_use_of_protected_member

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/check_logo_image_width.dart';
import 'package:xapptor_auth/account_view/fill_fields.dart';
import 'package:xapptor_auth/account_view/update_text_list.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/check_if_app_enabled.dart';
import 'package:xapptor_translation/translation_stream.dart';

extension StateExtension on AccountViewState {
  init_state() async {
    check_if_app_enabled();
    check_logo_image_width(
      context: context,
      logo_path: widget.logo_path,
      callback: (new_logo_image_width) => setState(() {
        logo_image_width = new_logo_image_width;
      }),
    );
    prefs = await SharedPreferences.getInstance();

    translation_stream = TranslationStream(
      translation_text_list_array: widget.text_list,
      update_text_list_function: update_text_list,
      list_index: 0,
      source_language_index: source_language_index,
    );

    if (widget.gender_values.list.isNotEmpty) {
      translation_stream_gender = TranslationStream(
        translation_text_list_array: widget.gender_values,
        update_text_list_function: update_text_list,
        list_index: 1,
        source_language_index: source_language_index,
      );

      translation_stream_list = [
        translation_stream,
        translation_stream_gender,
      ];
    } else {
      translation_stream_list = [
        translation_stream,
      ];
    }

    if (is_register(widget.auth_form_type)) {
      setState(() {
        gender_value = widget.gender_values.get(source_language_index)[0];
        country_value = widget.country_values?[0];
      });
    }

    if (is_edit_account(widget.auth_form_type)) fetch_fields();
  }
}
