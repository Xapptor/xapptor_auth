import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:xapptor_auth/auth_form_functions/check_user_token.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/check_biometrics.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/signin_with_google.dart';
import 'package:xapptor_router/V2/app_screens_v2.dart';
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
            open_screen_v2("home");
          } else {
            if (current_login_providers == AvailableLoginProviders.all ||
                current_login_providers == AvailableLoginProviders.google) {
              // Listen for authentication events (replaces onCurrentUserChanged)
              auth_events_subscription?.cancel();
              auth_events_subscription = GoogleSignIn.instance.authenticationEvents.listen(
                (GoogleSignInAuthenticationEvent event) async {
                  if (event is GoogleSignInAuthenticationEventSignIn) {
                    GoogleSignInAccount google_signin_account = event.user;
                    debugPrint("User is authorized from Google");
                    signin_with_google(google_signin_account);
                  }
                },
                onError: (error) {
                  debugPrint("Google Sign-In auth event error: $error");
                },
              );

              // Attempt lightweight authentication (replaces signInSilently)
              GoogleSignInAccount? google_signin_account =
                  await GoogleSignIn.instance.attemptLightweightAuthentication();

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
