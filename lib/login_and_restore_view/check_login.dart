// ignore_for_file: invalid_use_of_protected_member, use_build_context_synchronously

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
        google_signin!.onCurrentUserChanged.listen((GoogleSignInAccount? google_signin_account) async {
          bool is_authorized = google_signin_account != null;

          if (kIsWeb && google_signin_account != null) {
            is_authorized = await google_signin!.canAccessScopes(google_signin_scopes);
          }

          if (is_authorized) signin_with_google(google_signin_account!);
        });

        await google_signin!.signInSilently();

        GoogleSignInAccount? google_signin_account = google_signin!.currentUser;

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
