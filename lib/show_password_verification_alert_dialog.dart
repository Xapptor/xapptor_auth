import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_auth/auth_form_functions.dart';
import 'package:xapptor_logic/form_field_validators.dart';

show_authentication_alert_dialog({
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

    String? phone_number = FirebaseAuth.instance.currentUser!.phoneNumber;
    bool phone_number_auth = phone_number != null && email.isEmpty;

    String alert_title = phone_number_auth
        ? "Enter sms verification code"
        : "Enter current password";

    String textfield_label =
        phone_number_auth ? "Verification code" : "Password";

    late TextEditingController phone_input_controller;
    late SharedPreferences prefs;
    late AuthFormFunctions auth_form_functions;
    late ValueNotifier<bool> verification_code_sent;

    if (phone_number_auth) {
      phone_input_controller = TextEditingController();
      phone_input_controller.text = phone_number;

      prefs = await SharedPreferences.getInstance();

      auth_form_functions = AuthFormFunctions();

      verification_code_sent = ValueNotifier<bool>(false);

      await auth_form_functions.login_phone_number(
        context: context,
        input_controllers: [
          phone_input_controller,
          password_input_controller,
        ],
        prefs: prefs,
        verification_code_sent: verification_code_sent,
        update_verification_code_sent: () {
          verification_code_sent.value = true;
        },
        persistence: Persistence.LOCAL,
        remember_me: true,
        callback: () {},
      );
    }

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(alert_title),
          content: TextFormField(
            decoration: InputDecoration(
              labelText: textfield_label,
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
                if (phone_number_auth) {
                  await auth_form_functions.login_phone_number(
                    context: context,
                    input_controllers: [
                      phone_input_controller,
                      password_input_controller,
                    ],
                    prefs: prefs,
                    verification_code_sent: verification_code_sent,
                    update_verification_code_sent: () {
                      verification_code_sent.value = true;
                    },
                    persistence: Persistence.LOCAL,
                    remember_me: true,
                    callback: () {
                      callback();
                    },
                  );
                } else {
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
                }
              },
            ),
          ],
        );
      },
    );
  }
}
