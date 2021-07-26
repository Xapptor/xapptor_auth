import 'package:flutter/material.dart';
import 'package:xapptor_routing/app_screen.dart';
import 'package:xapptor_routing/app_screens.dart';
import 'package:xapptor_ui/screens/abeinstitute/home.dart' as Abeinstitute;
import 'package:xapptor_ui/screens/lum/home.dart' as Lum;
import 'package:xapptor_ui/values/version.dart';
import 'generic_user.dart';

open_home(GenericUser user) {
  add_new_app_screen(
    AppScreen(
      name: "home",
      child: get_current_home(user),
    ),
  );
  open_screen("home");
}

Widget get_current_home(GenericUser user) {
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
