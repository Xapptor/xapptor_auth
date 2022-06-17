import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_logic/firebase_tasks.dart';

class DeleteAccountAlertDialog extends StatefulWidget {
  const DeleteAccountAlertDialog({
    required this.text_list,
  });

  final List<String> text_list;

  @override
  State<DeleteAccountAlertDialog> createState() =>
      _DeleteAccountAlertDialogState();
}

class _DeleteAccountAlertDialogState extends State<DeleteAccountAlertDialog> {
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController password_input_controller = TextEditingController();

  Widget confirm_form_field() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: widget.text_list[2],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget confirm_button = StatefulBuilder(builder: (context, myState) {
      return Container(
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
              print("Login error: " + error.toString());

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.text_list.last),
                  duration: Duration(milliseconds: 1500),
                ),
              );
            });
          },
          child: Text(
            widget.text_list[widget.text_list.length - 2],
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    });

    return AlertDialog(
      title: Text(widget.text_list[1]),
      actions: [
        confirm_form_field(),
        confirm_button,
      ],
    );
  }
}
