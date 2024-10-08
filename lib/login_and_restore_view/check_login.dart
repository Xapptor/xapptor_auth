import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:xapptor_auth/auth_form_functions/check_user_token.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/check_biometrics.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/signin_with_google.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:flutter/foundation.dart';

extension StateExtension on LoginAndRestoreViewState {
  check_login() async {
    Timer(const Duration(milliseconds: 300), () async {
      bool user_token_is_valid = await check_user_token(
        renew: true,
      );

      check_biometrics(
        callback: () async {
          if (user_token_is_valid) {
            debugPrint("User is signed in from Firebase");
            open_screen("home");
          } else {
            if (current_login_providers == AvailableLoginProviders.all ||
                current_login_providers == AvailableLoginProviders.google) {
              google_signin!.onCurrentUserChanged.listen((GoogleSignInAccount? google_signin_account) async {
                bool is_authorized = google_signin_account != null;

                if (kIsWeb && google_signin_account != null) {
                  is_authorized = await google_signin!.canAccessScopes(google_signin_scopes);
                  if (!is_authorized) is_authorized = await google_signin!.requestScopes(google_signin_scopes);
                }

                debugPrint("User is authorized from Google: $is_authorized");
                if (is_authorized) signin_with_google(google_signin_account!);
              });

              await google_signin!.signInSilently();

              GoogleSignInAccount? google_signin_account = google_signin!.currentUser;

              if (google_signin_account != null) {
                debugPrint("User is signed in from Google");
                signin_with_google(google_signin_account);
              } else {
                _user_is_not_signed_in();
              }
            } else {
              _user_is_not_signed_in();
            }
          }
        },
      );
    });
  }

  _user_is_not_signed_in() {
    debugPrint("User is not signed in from Google");
  }
}
