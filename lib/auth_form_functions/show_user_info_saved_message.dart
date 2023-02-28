import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_logic/show_alert.dart';

extension ShowUserInfoSavedMessage on AuthFormFunctions {
  show_user_info_saved_message(BuildContext context) {
    Navigator.of(context).pop();
    show_success_alert(
      context: context,
      message: 'User info saved successfully',
      duration: Duration(seconds: 1),
    );
  }
}
