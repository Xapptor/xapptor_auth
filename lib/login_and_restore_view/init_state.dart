import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/check_if_app_enabled.dart';
import 'package:xapptor_auth/login_and_restore_view/check_login.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/update_text_list.dart';
import 'package:xapptor_translation/translation_stream.dart';

extension StateExtension on LoginAndRestoreViewState {
  init_state() async {
    check_if_app_enabled();

    if (!is_quick_login(widget.auth_form_type)) check_login();

    init_prefs();

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
}
