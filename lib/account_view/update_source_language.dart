// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_auth/account_view/account_view.dart';

extension UpdateSourceLanguage on AccountViewState {
  update_source_language({
    required int new_source_language_index,
  }) {
    source_language_index = new_source_language_index;
    setState(() {});
  }
}
