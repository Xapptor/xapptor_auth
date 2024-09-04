import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/google_button/google_button.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/third_party_signin_method_shape.dart';

extension StateExtension on LoginAndRestoreViewState {
  Widget google_button({
    HandleSignInFn? on_pressed,
  }) {
    double screen_width = MediaQuery.of(context).size.width;

    return widget.available_login_providers == AvailableLoginProviders.all ||
            widget.available_login_providers == AvailableLoginProviders.google
        ? SignInButton(
            Buttons.google,
            shape: third_party_signin_method_shape(screen_width),
            onPressed: on_pressed ?? () {},
          )
        : Container();
  }
}
