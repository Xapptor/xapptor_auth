import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_logic/copy_to_clipboard.dart';
import 'package:xapptor_ui/values/ui.dart';

extension UserIDButton on AccountViewState {
  Widget user_id_button() {
    User user = FirebaseAuth.instance.currentUser!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 10,
          child: Container(
            margin: EdgeInsets.only(bottom: sized_box_space),
            child: TextButton(
              onPressed: () {
                copy_to_clipboard(
                  data: user.uid,
                  message: "User ID copied to clipboard",
                  context: context,
                );
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.grey.withOpacity(0.3),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(outline_border_radius),
                    ),
                  ),
                ),
              ),
              child: Text(
                "User ID: ${user.uid}",
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }
}
