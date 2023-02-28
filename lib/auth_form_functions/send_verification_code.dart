import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_functions/login_phone_number.dart';
import 'package:xapptor_logic/show_alert.dart';

extension SendVerificationCode on AuthFormFunctions {
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
}
