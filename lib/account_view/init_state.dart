// ignore_for_file: invalid_use_of_protected_member, use_build_context_synchronously

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/account_view/get_user_country.dart';
import 'package:xapptor_auth/check_logo_image_width.dart';
import 'package:xapptor_auth/account_view/fill_fields.dart';
import 'package:xapptor_auth/account_view/update_text_list.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/check_if_app_enabled.dart';
import 'package:xapptor_translation/translation_stream.dart';

extension StateExtension on AccountViewState {
  init_state() async {
    check_if_app_enabled();

    // Load saved language preference first
    await _load_saved_language();

    // Initialize translation streams with the correct language
    _init_translation_streams();

    // Trigger rebuild to show LanguagePicker with correct translations
    if (mounted) {
      setState(() {});
    }

    if (is_register(widget.auth_form_type)) {
      gender_value = widget.gender_values.get(source_language_index)[0];
      setState(() {});

      await get_user_country().then((country) {
        country_value = country.name;
        setState(() {});
      });
    }

    if (is_edit_account(widget.auth_form_type)) fetch_fields();

    check_logo_image_width(
      context: context,
      logo_path: widget.logo_path,
      callback: (new_logo_image_width) => setState(() {
        logo_image_width = new_logo_image_width;
      }),
    );
    prefs = await SharedPreferences.getInstance();
  }

  /// Load saved language preference from SharedPreferences
  Future<void> _load_saved_language() async {
    final prefs = await SharedPreferences.getInstance();
    final target_language = prefs.getString('target_language');

    if (target_language != null) {
      // Find the index of the saved language in the text list array
      for (int i = 0; i < widget.text_list.list.length; i++) {
        if (widget.text_list.list[i].source_language == target_language) {
          // Always update to ensure correct language is applied
          source_language_index = i;
          break;
        }
      }
    }
    // Always trigger rebuild after loading language preference
    if (mounted) {
      setState(() {});
    }
  }

  /// Initialize translation streams with current source_language_index
  void _init_translation_streams() {
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
  }
}
