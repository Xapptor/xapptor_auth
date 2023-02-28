import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/model/xapptor_user.dart';
import 'package:xapptor_logic/show_alert.dart';
import 'package:xapptor_router/app_screens.dart';

extension Register on AuthFormFunctions {
  register({
    required BuildContext context,
    required bool accept_terms,
    required GlobalKey<FormState> register_form_key,
    required List<TextEditingController> input_controllers,
    required DateTime selected_date,
    required int gender_value,
    required String country_value,
    required String birthday_label,
  }) {
    TextEditingController firstname_input_controller = input_controllers[0];
    TextEditingController lastname_input_controller = input_controllers[1];
    TextEditingController email_input_controller = input_controllers[2];
    TextEditingController confirm_email_input_controller = input_controllers[3];
    TextEditingController password_input_controller = input_controllers[4];
    TextEditingController confirm_password_input_controller =
        input_controllers[5];

    if (accept_terms) {
      if (birthday_label != "") {
        if (register_form_key.currentState!.validate()) {
          if (email_input_controller.text ==
              confirm_email_input_controller.text) {
            if (password_input_controller.text ==
                confirm_password_input_controller.text) {
              FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                email: email_input_controller.text,
                password: password_input_controller.text,
              )
                  .then((current_user) async {
                FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email_input_controller.text,
                  password: password_input_controller.text,
                );

                Timestamp birthday_timestamp =
                    Timestamp.fromDate(selected_date);

                XapptorUser xapptor_user = XapptorUser(
                  id: current_user.user!.uid,
                  firstname: firstname_input_controller.text,
                  lastname: lastname_input_controller.text,
                  email: email_input_controller.text,
                  birthday: birthday_timestamp.toDate(),
                  gender: gender_value,
                  country: country_value,
                  admin: false,
                  owner: false,
                  roles: [],
                );

                FirebaseFirestore.instance
                    .collection("users")
                    .doc(current_user.user!.uid)
                    .set(xapptor_user.to_json())
                    .then((result) {
                  firstname_input_controller.clear();
                  lastname_input_controller.clear();
                  email_input_controller.clear();
                  confirm_email_input_controller.clear();
                  password_input_controller.clear();
                  confirm_password_input_controller.clear();

                  open_screen("login");
                }).catchError((err) {
                  print(err);
                });

                try {
                  await current_user.user!.sendEmailVerification();
                  return current_user.user!.uid;
                } catch (e) {
                  print(
                      "An error occured while trying to send email verification");
                  print(e);
                }
                return current_user;
              }).onError((error, stackTrace) {
                if (error.toString().contains("email") &&
                    error.toString().contains("already") &&
                    error.toString().contains("use")) {
                  show_error_alert(
                    context: context,
                    message: 'The email address is already registered',
                  );
                }

                return error.toString();
              });
            } else {
              show_neutral_alert(
                context: context,
                message: 'The passwords do not match',
              );
            }
          } else {
            show_neutral_alert(
              context: context,
              message: 'The emails do not match',
            );
          }
        }
      } else {
        show_neutral_alert(
          context: context,
          message: 'Enter your date of birth',
        );
      }
    } else {
      show_neutral_alert(
        context: context,
        message: 'You need to accept the terms of use & privacy policy',
      );
    }
  }
}
