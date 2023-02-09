import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_logic/form_field_validators.dart';

show_password_verification_alert_dialog({
  required BuildContext context,
  required String email,
  required Color text_color,
  required Function callback,
  required bool enabled,
}) async {
  if (!enabled) {
    callback();
  } else {
    TextEditingController password_input_controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter current password"),
          content: TextFormField(
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(
                color: text_color,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: text_color,
                ),
              ),
            ),
            controller: password_input_controller,
            validator: (value) => FormFieldValidators(
              value: value!,
              type: FormFieldValidatorsType.password,
            ).validate(),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Accept"),
              onPressed: () async {
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                  email: email,
                  password: password_input_controller.text,
                )
                    .then((UserCredential userCredential) async {
                  callback();
                }).catchError((onError) {
                  print(onError);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("The password is invalid"),
                    duration: Duration(milliseconds: 1500),
                  ));
                });
              },
            ),
          ],
        );
      },
    );
  }
}
