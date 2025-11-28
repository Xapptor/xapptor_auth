import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_ui/utils/copy_to_clipboard.dart';
import 'package:xapptor_ui/values/ui.dart';

extension StateExtension on AccountViewState {
  Widget? user_id_button() {
    User? user = FirebaseAuth.instance.currentUser;

    return user == null
        ? null
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: Container(
                  margin: const EdgeInsets.only(bottom: sized_box_space),
                  child: TextButton(
                    onPressed: () {
                      copy_to_clipboard(
                        data: user.uid,
                        message: "User ID copied to clipboard",
                        context: context,
                      );
                    },
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.grey.withValues(alpha: 0.3),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
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
