import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_logic/copy_to_clipboard.dart';

extension UserIDButton on AccountViewState {
  Widget user_id_button() {
    User user = FirebaseAuth.instance.currentUser!;
    return TextButton(
      onPressed: () {
        copy_to_clipboard(
          data: user.uid,
          message: "User ID copied to clipboard",
          context: context,
        );
      },
      child: Text(
        "User ID: ${user.uid}",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
