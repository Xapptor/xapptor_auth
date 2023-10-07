// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_auth/account_view/account_view.dart';

extension StateExtension on AccountViewState {
  update_text_list({
    required int index,
    required String new_text,
    required int list_index,
  }) {
    if (list_index == 0) {
      widget.text_list.get(source_language_index)[index] = new_text;
    } else if (list_index == 1) {
      widget.gender_values.get(source_language_index)[index] = new_text;

      if (gender_index == index) {
        gender_value = new_text;
      }
    }
    setState(() {});
  }
}
