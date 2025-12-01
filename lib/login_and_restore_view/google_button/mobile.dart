import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/google_button/unsupported.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/third_party_signin_method_shape.dart';
import 'package:xapptor_auth/translation_text_values.dart';

extension StateExtension on LoginAndRestoreViewState {
  Widget? google_button({
    HandleSignInFn? on_pressed,
  }) {
    double screen_width = MediaQuery.of(context).size.width;

    return widget.available_login_providers == AvailableLoginProviders.all ||
            widget.available_login_providers == AvailableLoginProviders.google
        ? SignInButtonBuilder(
            text: social_login_values.get(source_language_index)[1], // "Sign in with Google"
            image: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/48px-Google_%22G%22_logo.svg.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.g_mobiledata,
                size: 24,
                color: Colors.red,
              ),
            ),
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            shape: third_party_signin_method_shape(screen_width),
            onPressed: on_pressed ?? () {},
          )
        : null;
  }
}
