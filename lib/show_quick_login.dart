import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/login_and_restore_view.dart';
import 'package:xapptor_router/app_screen.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

show_quick_login(BuildContext context) {
  AppScreen app_screen = search_screen('login');
  LoginAndRestoreView login_widget = app_screen.child as LoginAndRestoreView;
  login_widget.auth_form_type = AuthFormType.quick_login;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool portrait = is_portrait(context);
      double screen_height = MediaQuery.of(context).size.height;
      double screen_width = MediaQuery.of(context).size.width;

      return AlertDialog(
        title: Text("Login"),
        content: Container(
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
