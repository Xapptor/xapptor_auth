// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_ui/values/country_phone_codes.dart';

extension StateExtension on LoginAndRestoreViewState {
  check_remember_me() async {
    if (use_email_signin) {
      if (prefs.getString("email") != null) {
        email_input_controller.text = prefs.getString("email")!;
        remember_me = true;
        setState(() {});
      }
    } else {
      if (prefs.getString("phone_number") != null || prefs.getString("phone_code") != null) {
        if (prefs.getString("phone_number") != null) {
          email_input_controller.text = prefs.getString("phone_number")!;
        }
        if (prefs.getString("phone_code") != null) {
          current_phone_code.value = country_phone_code_list.firstWhere(
            (element) => element.dial_code == prefs.getString("phone_code"),
            orElse: () => country_phone_code_list[0],
          );
        }
      }
      remember_me = true;
      setState(() {});
    }
  }
}
