import 'package:flutter/material.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';

extension ThirdPartySigninMethodShape on LoginAndRestoreViewState {
  ShapeBorder third_party_signin_method_shape(double screen_width) {
    return RoundedRectangleBorder(
      side: BorderSide(
        color: widget.text_color,
      ),
      borderRadius: BorderRadius.circular(screen_width),
    );
  }
}
