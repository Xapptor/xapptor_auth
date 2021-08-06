import 'package:flutter/material.dart';
import 'package:xapptor_router/app_screen.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_ui/screens/abeinstitute/home.dart' as Abeinstitute;
import 'package:xapptor_ui/screens/lum/home.dart' as Lum;
import 'package:xapptor_ui/values/version.dart';
import 'xapptor_user.dart';

open_home(XapptorUser user) {
  add_new_app_screen(
    AppScreen(
      name: "home",
      child: get_current_home(user),
    ),
  );
  open_screen("home");
}

Widget get_current_home(XapptorUser user) {
  if (app_name == "abeinstitute") {
    return Abeinstitute.Home(
      user: user,
    );
  } else {
    return Lum.Home(
      user: user,
    );
  }
}
