import 'dart:async';
import 'package:universal_platform/universal_platform.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_ui/widgets/show_custom_dialog.dart';

// Functions executed in Auth Screens.

class AuthFormFunctions {
  // Login

  late ConfirmationResult confirmation_result;
  String verification_id = '';

  show_verification_code_sent_alert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
        content: Text(
          'Verification code sent',
        ),
      ),
    );
  }

  login_phone_number({
    required BuildContext context,
    required GlobalKey<FormState> login_form_key,
    required List<TextEditingController> input_controllers,
    required SharedPreferences prefs,
    required ValueNotifier<bool> verification_code_sent,
    required Persistence persistence,
    required Function setState,
  }) async {
    TextEditingController phone_input_controller = input_controllers[0];
    TextEditingController code_input_controller = input_controllers[0];

    if (UniversalPlatform.isWeb) {
      // Set persistence in Web.
      await FirebaseAuth.instance.setPersistence(persistence);

      if (!verification_code_sent.value) {
        confirmation_result = await FirebaseAuth.instance
            .signInWithPhoneNumber(phone_input_controller.text)
            .catchError((error) => print(error));

        verification_id = confirmation_result.verificationId;
        verification_code_sent.value = true;
        setState(() {});
        show_verification_code_sent_alert(context);
      } else {
        final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verification_id,
          smsCode: code_input_controller.text,
        );

        FirebaseAuth.instance.signInWithCredential(credential).then((value) {
          verification_code_sent.value = false;
          phone_input_controller.clear();
          code_input_controller.clear();
          setState(() {});
          open_screen("home");
        });
      }
    } else {
//       FirebaseAuth _auth = FirebaseAuth.instance;
//           _auth.verifyPhoneNumber(
//               phoneNumber: '+2$mobile',
//               timeout: Duration(seconds: 60),
//               verificationCompleted: (AuthCredential authCredential){
//                 var _credential = PhoneAuthProvider.credential(verificationId: actualCode, smsCode: smsCodeController.text);
//                 _auth.signInWithCredential(_credential).then((UserCredential result) async {
//                   pr.hide();
//                   setState(() {
//                     status = 'Authentication successful';
//                   });
// //The rest of my success code
//                 }).catchError((e){
//                   print(e);
//                   Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(
//                           builder: (context) => Welcome()),
//                           (Route<dynamic> route) => false);
// };
//               },
//               verificationFailed: (FirebaseAuthException  authException){
//                 print(authException.message);
//               },
//               codeSent: (String verificationId, [int forceResendingToken]){
//                 setState(() {
//                   actualCode = verificationId;
//                   status = 'Code sent';
//                 });
//               },
//               codeAutoRetrievalTimeout: (String verificationId){
//                 verificationId = verificationId;
//                 print(verificationId);
//                 setState(() {
//                   status = 'Auto retrieval timeout';
//                 });
//               },
//               );
    }
  }

  login({
    required BuildContext context,
    required bool remember_me,
    required GlobalKey<FormState> login_form_key,
    required List<TextEditingController> input_controllers,
    required SharedPreferences prefs,
    required Persistence persistence,
    required bool verify_email,
  }) async {
    TextEditingController email_input_controller = input_controllers[0];
    TextEditingController password_input_controller = input_controllers[1];

    if (login_form_key.currentState!.validate()) {
      // Set persistence in Web.
      if (UniversalPlatform.isWeb)
        await FirebaseAuth.instance.setPersistence(persistence);

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email_input_controller.text,
        password: password_input_controller.text,
      )
          .then((UserCredential value) async {
        User user = value.user!;
        String uid = user.uid;

        DocumentSnapshot snapshot_user =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();

        if (verify_email) {
          if (value.user!.emailVerified) {
            if (remember_me) prefs.setString("email", value.user!.email!);
            email_input_controller.clear();
            password_input_controller.clear();
            open_screen("home");
          } else {
            show_email_verification_alert_dialog(
              context: context,
              user: value.user!,
            );
          }
        } else {
          if (remember_me) prefs.setString("email", value.user!.email!);
          email_input_controller.clear();
          password_input_controller.clear();
          open_screen("home");
        }

        return null;
      }).catchError((error) {
        print("Login error: " + error.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("The password or email are invalid"),
            duration: Duration(milliseconds: 1500),
          ),
        );
      });
    }
  }

  // The user has not verified his email.

  show_email_verification_alert_dialog({
    required BuildContext context,
    required User user,
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("You haven't verified your email yet"),
          content: Text("Would you like to send an email verification?"),
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
                await user.sendEmailVerification().then((value) {
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Register

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

                FirebaseFirestore.instance
                    .collection("users")
                    .doc(current_user.user!.uid)
                    .set({
                  "firstname": firstname_input_controller.text,
                  "lastname": lastname_input_controller.text,
                  "birthday": birthday_timestamp,
                  "gender": gender_value,
                  "country": country_value,
                }).then((result) {
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("The email address is already registered."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                return error.toString();
              });
            } else {
              show_custom_dialog(
                context: context,
                title: "Failed",
                message: "The passwords do not match",
                button_text: "Close",
              );
            }
          } else {
            show_custom_dialog(
              context: context,
              title: "Failed",
              message: "The emails do not match",
              button_text: "Close",
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Enter your date of birth"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You need to accept the terms of use & privacy policy"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Restore Password

  restore_password({
    required BuildContext context,
    required GlobalKey<FormState> restore_password_form_key,
    required TextEditingController email_input_controller,
  }) async {
    if (restore_password_form_key.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: email_input_controller.text)
            .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              content: Text(
                'Restore password email sent successfully',
              ),
            ),
          );
          open_screen("login");
        });
      } catch (e) {
        print("An error occured while trying to send password reset email");
        print(e);
      }
    }
  }

  // Update User Email

  update_user_email({
    required BuildContext context,
    required GlobalKey<ScaffoldState> scaffold_key,
    required GlobalKey<FormState> email_form_key,
    required List<TextEditingController> input_controllers,
    required String user_id,
    required bool password_verification_enabled,
  }) async {
    TextEditingController email_input_controller = input_controllers[0];
    TextEditingController confirm_email_input_controller = input_controllers[1];

    if (email_form_key.currentState!.validate()) {
      if (email_input_controller.text == confirm_email_input_controller.text) {
        User user = FirebaseAuth.instance.currentUser!;

        user.updateEmail(email_input_controller.text).then((value) {
          FirebaseFirestore.instance.collection("users").doc(user_id).update({
            "email": email_input_controller.text,
          }).then((result) async {
            try {
              await user.sendEmailVerification();
            } catch (e) {
              print("An error occured while trying to send email verification");
              print(e);
            }

            show_user_info_saved_message(
                context, password_verification_enabled ? 2 : 1);
          }).catchError((err) {
            print(err);
          });
        });
      } else {
        show_custom_dialog(
          context: context,
          title: "Failed",
          message: "The emails do not match",
          button_text: "Close",
        );
      }
    }
  }

  // Update User Password

  Future update_user_password({
    required BuildContext context,
    required GlobalKey<ScaffoldState> scaffold_key,
    required GlobalKey<FormState> password_form_key,
    required List<TextEditingController> input_controllers,
    required String user_id,
    required String email,
    required bool password_verification_enabled,
  }) async {
    TextEditingController password_input_controller = input_controllers[0];
    TextEditingController confirm_password_input_controller =
        input_controllers[1];

    if (password_form_key.currentState!.validate()) {
      if (password_input_controller.text ==
          confirm_password_input_controller.text) {
        User user = FirebaseAuth.instance.currentUser!;

        user.updatePassword(password_input_controller.text).then((_) {
          show_user_info_saved_message(
              context, password_verification_enabled ? 3 : 2);
        }).catchError((error) {
          print("Password can't be changed " + error.toString());
        });
      } else {
        show_custom_dialog(
          context: context,
          title: "Failed",
          message: "The passwords do not match",
          button_text: "Close",
        );
      }
    }
  }

  // Update User Info

  update_user_name_and_info({
    required BuildContext context,
    required GlobalKey<ScaffoldState> scaffold_key,
    required GlobalKey<FormState> name_and_info_form_key,
    required List<TextEditingController> input_controllers,
    required DateTime selected_date,
    required int gender_value,
    required String country_value,
    required String user_id,
    required bool password_verification_enabled,
  }) {
    TextEditingController firstname_input_controller = input_controllers[0];
    TextEditingController lastname_input_controller = input_controllers[1];

    Timestamp birthday_timestamp = Timestamp.fromDate(selected_date);

    if (name_and_info_form_key.currentState!.validate()) {
      FirebaseFirestore.instance.collection("users").doc(user_id).update({
        "firstname": firstname_input_controller.text,
        "lastname": lastname_input_controller.text,
        "birthday": birthday_timestamp,
        "gender": gender_value,
        "country": country_value,
      }).then((result) {
        show_user_info_saved_message(
            context, password_verification_enabled ? 2 : 1);
      }).catchError((err) {
        print(err);
      });
    }
  }

  show_user_info_saved_message(BuildContext context, int times_pop) {
    for (int i = 0; 0 < times_pop; i++) {
      Navigator.of(context).pop();
    }

    Timer(Duration(milliseconds: 500), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User info saved"),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }
}
