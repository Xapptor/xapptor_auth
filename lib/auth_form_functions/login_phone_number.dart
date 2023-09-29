import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_functions/send_verification_code.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/model/xapptor_user.dart';
import 'package:xapptor_auth/show_quick_login.dart';
import 'package:xapptor_logic/show_alert.dart';
import 'package:xapptor_router/app_screens.dart';

extension LoginPhoneNumber on AuthFormFunctions {
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
    if (UniversalPlatform.isWeb) {
      await FirebaseAuth.instance.setPersistence(persistence);
    }

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
}
