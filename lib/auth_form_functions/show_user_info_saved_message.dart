import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_ui/utils/show_alert.dart';

extension ShowUserInfoSavedMessage on AuthFormFunctions {
  show_user_info_saved_message(BuildContext context) {
    show_success_alert(
      context: context,
      message: 'User info saved successfully',
      delay: const Duration(seconds: 1),
    );

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
  }
}
