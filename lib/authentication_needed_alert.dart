import 'package:flutter/material.dart';
import 'package:xapptor_router/app_screens.dart';

authentication_needed_alert({
  required BuildContext context,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("First you need to authenticate yourself"),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Accept"),
            onPressed: () async {
              Navigator.of(context).pop();
              open_screen("login");
            },
          ),
        ],
      );
    },
  );
}
