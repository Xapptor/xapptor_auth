import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_ui/utils/is_portrait.dart';

show_quick_login({
  required BuildContext context,
  required AvailableLoginProviders available_login_providers,
  String message = "Re-Authentication",
  Function? callback,
}) {
  LoginAndRestoreView login_widget = search_screen('login').child as LoginAndRestoreView;
  login_widget.auth_form_type = AuthFormType.quick_login;
  login_widget.available_login_providers = available_login_providers;
  login_widget.quick_login_callback = callback;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool portrait = is_portrait(context);
      double screen_width = MediaQuery.of(context).size.width;

      return AlertDialog(
        scrollable: true,
        title: Text(message),
        insetPadding: EdgeInsets.all(portrait ? 10 : 20),
        contentPadding: EdgeInsets.all(portrait ? 10 : 20),
        content: Container(
          width: screen_width * (portrait ? 1 : 0.3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: login_widget,
        ),
      );
    },
  );
}
