import 'dart:async';
import 'package:universal_platform/universal_platform.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_auth/login_and_restore_view.dart';
import 'package:xapptor_auth/model/xapptor_user.dart';
import 'package:xapptor_auth/show_quick_login.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_logic/show_alert.dart';

// Functions executed in Auth Screens.

class AuthFormFunctions {
  ConfirmationResult? confirmation_result;
  String? verification_id = '';

  AuthFormFunctions({
    this.confirmation_result,
    this.verification_id,
  });

  send_verification_code({
    required BuildContext context,
    required TextEditingController phone_input_controller,
    required TextEditingController code_input_controller,
    required SharedPreferences prefs,
    required Function update_verification_code_sent,
    required bool remember_me,
    required Function? callback,
  }) async {
    // print(phone_input_controller.text);

    if (UniversalPlatform.isWeb) {
      await FirebaseAuth.instance
          .signInWithPhoneNumber(phone_input_controller.text)
          .then((value) {
        confirmation_result = value;
        verification_id = confirmation_result!.verificationId;
        update_verification_code_sent();
        show_success_alert(
          context: context,
          message: 'Verification code sent',
        );
      }).onError((error, stackTrace) {
        print(error);

        if (error.toString().contains('blocked')) {
          show_error_alert(
            context: context,
            message: 'Device blocked due to unusual activity. Try again later.',
          );
        } else {
          show_error_alert(
            context: context,
            message: 'The phone number is invalid',
          );
        }
      });
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone_input_controller.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential user_credential =
              await FirebaseAuth.instance.signInWithCredential(credential);

          complete_login_phone_number(
            user_credential: user_credential,
            phone_input_controller: phone_input_controller,
            code_input_controller: code_input_controller,
            update_verification_code_sent: update_verification_code_sent,
            prefs: prefs,
            remember_me: remember_me,
            callback: callback,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          show_error_alert(
            context: context,
            message: 'The phone number is invalid',
          );
        },
        codeSent: (String new_verification_id, int? resend_token) {
          verification_id = new_verification_id;
        },
        codeAutoRetrievalTimeout: (String verification_id) {},
      );
    }
  }

  save_phone_prefs({
    required TextEditingController phone_input_controller,
    required SharedPreferences prefs,
  }) {
    if (phone_input_controller.text.contains(' ')) {
      prefs.setString(
          "phone_number", phone_input_controller.text.split(' ').last);
      prefs.setString(
          "phone_code", phone_input_controller.text.split(' ').first);
    }
  }

  complete_login_phone_number({
    required UserCredential user_credential,
    required TextEditingController phone_input_controller,
    required TextEditingController code_input_controller,
    required Function update_verification_code_sent,
    required SharedPreferences prefs,
    required bool remember_me,
    required Function? callback,
  }) async {
    XapptorUser xapptor_user = XapptorUser.empty();
    xapptor_user.id = user_credential.user!.uid;

    var user = await FirebaseFirestore.instance
        .collection('users')
        .doc(xapptor_user.id)
        .get();
    if (user.exists) {
      if (remember_me) {
        save_phone_prefs(
          phone_input_controller: phone_input_controller,
          prefs: prefs,
        );
      }

      phone_input_controller.clear();
      code_input_controller.clear();
      update_verification_code_sent();

      if (callback != null) {
        callback();
      } else {
        open_screen("home");
      }
    } else {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user_credential.user!.uid)
          .set(xapptor_user.to_json())
          .then((value) {
        if (remember_me) {
          save_phone_prefs(
            phone_input_controller: phone_input_controller,
            prefs: prefs,
          );
        }

        phone_input_controller.clear();
        code_input_controller.clear();
        update_verification_code_sent();

        if (callback != null) {
          callback();
        } else {
          open_screen("home");
        }
      });
    }
  }

  // Login with sms verification code

  login_phone_number({
    required BuildContext context,
    required List<TextEditingController> input_controllers,
    required SharedPreferences prefs,
    required ValueNotifier<bool> verification_code_sent,
    required Function update_verification_code_sent,
    required Persistence persistence,
    required bool remember_me,
    Function? callback,
  }) async {
    TextEditingController phone_input_controller = input_controllers[0];
    TextEditingController code_input_controller = input_controllers[1];

    // Set persistence in Web.
    if (UniversalPlatform.isWeb)
      await FirebaseAuth.instance.setPersistence(persistence);

    if (!verification_code_sent.value) {
      send_verification_code(
        context: context,
        phone_input_controller: phone_input_controller,
        code_input_controller: code_input_controller,
        prefs: prefs,
        update_verification_code_sent: update_verification_code_sent,
        remember_me: remember_me,
        callback: callback,
      );
    } else {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verification_id!,
        smsCode: code_input_controller.text,
      );

      if (FirebaseAuth.instance.currentUser != null &&
          FirebaseAuth.instance.currentUser?.phoneNumber == null) {
        await FirebaseAuth.instance.currentUser
            ?.linkWithCredential(credential)
            .then((value) {
          Navigator.pop(context);
          show_success_alert(
            context: context,
            message: 'Phone linked successfully',
          );
          if (callback != null) callback();
        }).onError((error, stackTrace) {
          print(error.toString());

          if (error.toString().contains('requires recent authentication')) {
            show_quick_login(
              context: context,
              available_login_providers: AvailableLoginProviders.email,
            );
          } else {
            show_error_alert(
              context: context,
              message: 'Error linking phone',
            );
          }
        });
      } else {
        if (confirmation_result != null) {
          await confirmation_result!
              .confirm(code_input_controller.text)
              .then((UserCredential user_credential) {
            complete_login_phone_number(
              user_credential: user_credential,
              phone_input_controller: phone_input_controller,
              code_input_controller: code_input_controller,
              update_verification_code_sent: update_verification_code_sent,
              prefs: prefs,
              remember_me: remember_me,
              callback: callback,
            );
          }).onError((error, stackTrace) {
            show_error_alert(
              context: context,
              message: 'The verification code is invalid',
            );
          });
        } else {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((UserCredential user_credential) {
            complete_login_phone_number(
              user_credential: user_credential,
              phone_input_controller: phone_input_controller,
              code_input_controller: code_input_controller,
              update_verification_code_sent: update_verification_code_sent,
              prefs: prefs,
              remember_me: remember_me,
              callback: callback,
            );
          }).onError((error, stackTrace) {
            show_error_alert(
              context: context,
              message: 'The verification code is invalid',
            );
          });
        }
      }
    }
  }

  // Login with email and password

  login({
    required BuildContext context,
    required bool remember_me,
    required GlobalKey<FormState> form_key,
    required List<TextEditingController> input_controllers,
    required SharedPreferences prefs,
    required Persistence persistence,
    required bool verify_email,
  }) async {
    TextEditingController email_input_controller = input_controllers[0];
    TextEditingController password_input_controller = input_controllers[1];

    if (form_key.currentState!.validate()) {
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
        show_error_alert(
          context: context,
          message: 'The password or email are invalid',
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

  // Restore Password

  restore_password({
    required BuildContext context,
    required GlobalKey<FormState> form_key,
    required TextEditingController email_input_controller,
  }) async {
    if (form_key.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: email_input_controller.text)
            .then((value) {
          show_success_alert(
            context: context,
            message: 'Restore password email sent successfully',
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

        user.updateEmail(email_input_controller.text).then((result) async {
          try {
            await user.sendEmailVerification();
          } catch (e) {
            print("An error occured while trying to send email verification");
            print(e);
          }

          show_user_info_saved_message(context);
        }).catchError((err) {
          print(err);
        });
      } else {
        show_neutral_alert(
          context: context,
          message: 'The emails do not match',
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
          show_user_info_saved_message(context);
        }).catchError((error) {
          print("Password can't be changed " + error.toString());
        });
      } else {
        show_neutral_alert(
          context: context,
          message: 'The passwords do not match',
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
        show_user_info_saved_message(context);
      }).catchError((err) {
        print(err);
      });
    }
  }

  show_user_info_saved_message(BuildContext context) {
    Navigator.of(context).pop();
    show_success_alert(
      context: context,
      message: 'User info saved successfully',
      duration: Duration(seconds: 1),
    );
  }
}
