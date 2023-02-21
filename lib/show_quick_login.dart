import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/login_and_restore_view.dart';
import 'package:xapptor_router/app_screen.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

show_quick_login({
  required BuildContext context,
  required AvailableLoginProviders available_login_providers,
  String message = "Re-Authentication",
}) {
  AppScreen app_screen = search_screen('login');
  LoginAndRestoreView login_widget = app_screen.child as LoginAndRestoreView;
  login_widget.auth_form_type = AuthFormType.quick_login;
  login_widget.available_login_providers = available_login_providers;

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
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: login_widget,
        ),
      );
    },
  );
}
