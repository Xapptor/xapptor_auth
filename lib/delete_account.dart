import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_logic/firebase_tasks.dart';

delete_account({
  required List<String> text_list,
  required BuildContext context,
  required parent,
}) {
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController confirm_input_controller = TextEditingController();

  TextFormField confirm_form_field = TextFormField(
    onChanged: (text) {
      if (confirm_input_controller.text == user.email) {
        parent.confirm_button_color = Colors.red;
      } else {
        parent.confirm_button_color = Colors.grey;
      }
      parent.setState(() {});
    },
    decoration: InputDecoration(
      labelText: text_list[2],
      labelStyle: TextStyle(
        color: Colors.grey,
      ),
      hintStyle: TextStyle(
        color: Colors.grey,
      ),
    ),
    controller: confirm_input_controller,
  );

  print((parent.confirm_button_color as Color).toString());

  Widget confirm_button = Container(
    decoration: BoxDecoration(
      color: parent.confirm_button_color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: TextButton(
      onPressed: () {
        if (confirm_input_controller.text == user.email) {
          user.delete().then((value) async {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .delete();
            await delete_all_files_in_a_path(path: "users/${user.uid}");

            Navigator.of(context).pop();
          });
        }
      },
      child: Text(
        text_list.last,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );

  AlertDialog alert = AlertDialog(
    title: Text(text_list[1]),
    actions: [
      confirm_form_field,
      confirm_button,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
