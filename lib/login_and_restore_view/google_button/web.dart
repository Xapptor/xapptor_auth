import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/google_button/unsupported.dart';

extension StateExtension on LoginAndRestoreViewState {
  Widget? google_button({
    HandleSignInFn? on_pressed,
  }) {
    return widget.available_login_providers == AvailableLoginProviders.all ||
            widget.available_login_providers == AvailableLoginProviders.google
        ? web.renderButton()
        : null;
  }
}
