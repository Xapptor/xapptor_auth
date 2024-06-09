// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_functions/send_verification_code.dart';
import 'package:xapptor_auth/check_provider.dart';
import 'package:xapptor_logic/firebase_tasks/delete.dart';
import 'package:xapptor_ui/utils/show_alert.dart';

delete_account({
  required BuildContext context,
  required List<String> text_list,
}) async {
  User user = FirebaseAuth.instance.currentUser!;
  TextEditingController password_input_controller = TextEditingController();

  List<UserInfo> user_providers = user.providerData;
  bool email_linked = check_email_provider(user_providers: user_providers);
  bool phone_linked = check_phone_provider(user_providers: user_providers);

  // bool email_linked = false;
  // bool phone_linked = false;

  AuthFormFunctions auth_form_functions = AuthFormFunctions();

  if (!email_linked && phone_linked) {
    TextEditingController phone_input_controller = TextEditingController();
    phone_input_controller.text = user.phoneNumber!;

    auth_form_functions.send_verification_code(
      context: context,
      phone_input_controller: phone_input_controller,
      code_input_controller: password_input_controller,
      prefs: await SharedPreferences.getInstance(),
      update_verification_code_sent: () {},
      remember_me: false,
      callback: () {},
    );
  }
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            text_list[email_linked
                ? 2
                : phone_linked
                    ? 3
                    : 1],
          ),
          actions: [
            !email_linked && !phone_linked
                ? Container()
                : Container(
                    margin: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: text_list[email_linked ? 4 : 5],
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      controller: password_input_controller,
                      maxLines: null,
                    ),
                  ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () async {
                  _check_signin_method(
                    context: context,
                    text_list: text_list,
                    user: user,
                    email_linked: email_linked,
                    phone_linked: phone_linked,
                    password_input_controller: password_input_controller,
                    auth_form_functions: auth_form_functions,
                  );
                },
                child: Text(
                  text_list[text_list.length - 3],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

_check_signin_method({
  required BuildContext context,
  required List<String> text_list,
  required User user,
  required bool email_linked,
  required bool phone_linked,
  required TextEditingController password_input_controller,
  required AuthFormFunctions auth_form_functions,
}) async {
  if (email_linked) {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: user.email!,
      password: password_input_controller.text,
    )
        .then((value) async {
      _delete_account(
        context: context,
        user: user,
      );
    }).catchError((error) {
      debugPrint(error);
      show_error_alert(context: context, message: text_list.last);
    });
  } else if (phone_linked) {
    if (auth_form_functions.confirmation_result != null) {
      auth_form_functions.confirmation_result!.confirm(password_input_controller.text).then((value) {
        _delete_account(
          context: context,
          user: user,
        );
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        show_error_alert(context: context, message: text_list.last);
      });
    } else {
      Navigator.pop(context);
      show_error_alert(context: context, message: text_list.last);
    }
  } else {
    _delete_account(
      context: context,
      user: user,
    );
  }
}

_delete_account({
  required BuildContext context,
  required User user,
}) async {
  await user.delete().then((value) async {
    await delete_all_files_in_a_path(path: "users/${user.uid}");
    await FirebaseFirestore.instance.collection("users").doc(user.uid).delete();
    if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }).onError((error, stackTrace) {
    debugPrint(error.toString());
    show_error_alert(context: context, message: error.toString());
  });
}
