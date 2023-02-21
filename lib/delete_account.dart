import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/check_provider.dart';
import 'package:xapptor_logic/firebase_tasks.dart';
import 'package:xapptor_ui/widgets/show_alert.dart';

delete_account({
  required BuildContext context,
  required List<String> text_list,
}) {
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController password_input_controller = TextEditingController();

  List<UserInfo> user_providers = user.providerData;
  bool email_linked = check_email_provider(user_providers: user_providers);
  bool phone_linked = check_phone_provider(user_providers: user_providers);

  Widget confirm_button = Container(
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(20),
    ),
    child: TextButton(
      onPressed: () async {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: user.email!,
          password: password_input_controller.text,
        )
            .then((value) async {
          await delete_all_files_in_a_path(path: "users/${user.uid}");

          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .delete();

          await user.delete();

          Navigator.of(context).popUntil((route) {
            return route.isFirst;
          });
        }).catchError((error) {
          print(error);
          show_error_alert(context: context, message: text_list.last);
        });
      },
      child: Text(
        text_list[text_list.length - 2],
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(text_list[1]),
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: text_list[2],
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
              controller: password_input_controller,
              maxLines: null,
            ),
          ),
          confirm_button,
        ],
      );
    },
  );
}
