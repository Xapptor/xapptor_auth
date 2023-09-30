// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

extension UpdateTextList on LoginAndRestoreViewState {
  update_text_list({
    required int index,
    required String new_text,
    required int list_index,
  }) {
    if (list_index == 0) {
      widget.text_list.get(source_language_index)[index] = new_text;
    } else if (list_index == 1) {
      widget.phone_signin_text_list!.get(source_language_index)[index] = new_text;
    }
    setState(() {});
  }
}
