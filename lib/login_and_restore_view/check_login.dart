// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_auth/check_logo_image_width.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/signin_with_google.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:flutter/foundation.dart';

extension StateExtension on LoginAndRestoreViewState {
  check_login() async {
    Timer(const Duration(milliseconds: 300), () async {
      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint("User is logged in");
        open_screen("home");
      } else {
        var google_signin_account = google_signin.currentUser;
        if (google_signin_account != null) {
          signin_with_google(google_signin_account);
        } else {
          debugPrint("User is not sign");
          check_logo_image_width(
            context: context,
            logo_path: widget.logo_path,
            callback: (new_logo_image_width) => setState(() {
              logo_image_width = new_logo_image_width;
            }),
          );
        }
      }
    });
  }
}
