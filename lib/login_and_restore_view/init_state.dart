import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/check_if_app_enabled.dart';
import 'package:xapptor_auth/login_and_restore_view/check_login.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/update_text_list.dart';
import 'package:xapptor_auth/phone_code_detection/phone_code_detector.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension StateExtension on LoginAndRestoreViewState {
  init_state() async {
    check_if_app_enabled();

    if (!is_quick_login(widget.auth_form_type)) check_login();

    init_prefs();

    // Detect phone country code based on IP address
    _detect_phone_country_code();

    // Load saved language preference first
    await _load_saved_language();

    // Initialize translation streams with the correct language
    _init_translation_streams();

    // Trigger rebuild to show LanguagePicker and update UI with correct translations
    if (mounted) {
      setState(() {});
    }
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

    if (widget.phone_signin_text_list != null) {
      translation_stream_phone = TranslationStream(
        translation_text_list_array: widget.phone_signin_text_list!,
        update_text_list_function: update_text_list,
        list_index: 1,
        source_language_index: source_language_index,
      );

      translation_stream_list = [
        translation_stream,
        translation_stream_phone,
      ];
    } else {
      translation_stream_list = [
        translation_stream,
      ];
    }
  }

  /// Detects and sets the phone country code based on user's IP address.
  _detect_phone_country_code() async {
    final detected_country = await detect_phone_country_code();
    current_phone_code.value = detected_country;
  }
}
