import 'package:xapptor_auth/account_view/account_view.dart';

extension ValidatePickerValue on AccountViewState {
  String validate_picker_value(String value, List<String> list) {
    bool match = false;
    for (var list_item in list) {
      if (list_item == value) match = true;
    }
    return match ? value : list.first;
  }
}
