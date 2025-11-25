import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

extension StateExtension on LoginAndRestoreViewState {
  Future<void> check_biometrics({
    required Function callback,
  }) async {
    if (widget.enable_biometrics) {
      if (UniversalPlatform.isWeb) {
        callback();
      } else {
        final LocalAuthentication auth = LocalAuthentication();

        try {
          if (await auth.canCheckBiometrics) {
            bool did_authenticate = await auth.authenticate(
              localizedReason: 'Please authenticate to access your account',
              biometricOnly: true,
            );

            if (did_authenticate) {
              debugPrint('User authenticated with biometrics');

              callback();
            } else {
              debugPrint('User did not authenticate with biometrics');
            }
          }
        } catch (e) {
          debugPrint('Error authenticating with biometrics: $e');
        }
      }
    } else {
      callback();
    }
  }
}
