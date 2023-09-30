// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

extension UpdateSourceLanguage on LoginAndRestoreViewState {
  update_source_language({
    required int new_source_language_index,
  }) {
    source_language_index = new_source_language_index;
    setState(() {});
  }
}
