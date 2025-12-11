import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/google_button/unsupported.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

extension StateExtension on LoginAndRestoreViewState {
  /// Returns Google's official Sign-In button for web.
  ///
  /// On web, this uses Google Identity Services (GIS) `renderButton()` which:
  /// - Handles authentication through Google's official UI
  /// - Returns an ID token with user info embedded (no People API needed)
  /// - Emits credentials via `userDataEvents` stream
  ///
  /// The [on_pressed] callback is ignored on web since the button
  /// handles its own click events internally.
  Widget? google_button({
    HandleSignInFn? on_pressed,
  }) {
    return widget.available_login_providers == AvailableLoginProviders.all ||
            widget.available_login_providers == AvailableLoginProviders.google
        ? gsi_web.renderButton()
        : null;
  }
}
