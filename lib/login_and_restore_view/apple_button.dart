import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/third_party_signin_method_shape.dart';
import 'package:xapptor_auth/signin_with_apple.dart';
import 'package:xapptor_auth/translation_text_values.dart';
import 'package:xapptor_logic/string/sha256_of_string.dart';

extension StateExtension on LoginAndRestoreViewState {
  Widget? apple_button() {
    double screen_width = MediaQuery.of(context).size.width;

    return widget.available_login_providers == AvailableLoginProviders.all ||
            widget.available_login_providers == AvailableLoginProviders.apple
        ? SignInButtonBuilder(
            text: social_login_values.get(source_language_index)[2], // "Sign in with Apple"
            icon: Icons.apple,
            backgroundColor: Colors.black,
            shape: third_party_signin_method_shape(screen_width),
            onPressed: () async {
              final raw_nonce = generateNonce();
              final nonce = sha256_of_string(raw_nonce);

              AuthorizationCredentialAppleID credential = await SignInWithApple.getAppleIDCredential(
                webAuthenticationOptions: WebAuthenticationOptions(
                  clientId: widget.apple_signin_client_id,
                  redirectUri: Uri.parse(widget.apple_signin_redirect_url),
                ),
                scopes: [
                  AppleIDAuthorizationScopes.email,
                  AppleIDAuthorizationScopes.fullName,
                ],
                nonce: nonce,
              );

              signin_with_apple(
                credential,
                raw_nonce,
              );
            },
          )
        : null;
  }
}
