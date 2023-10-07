import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/third_party_signin_method_shape.dart';
import 'package:xapptor_auth/signin_with_google.dart';

extension StateExtension on LoginAndRestoreViewState {
  google_button() async {
    double screen_width = MediaQuery.of(context).size.width;

    return widget.available_login_providers == AvailableLoginProviders.google
        ? SignInButton(
            Buttons.google,
            shape: third_party_signin_method_shape(screen_width),
            onPressed: () async {
              GoogleSignInAccount? google_signin_account = await handle_google_signin();
              if (google_signin_account != null) {
                signin_with_google(google_signin_account);
              }
            },
          )
        : Container();
  }
}
