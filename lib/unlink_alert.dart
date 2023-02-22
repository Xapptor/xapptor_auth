import 'package:flutter/material.dart';

unlink_alert({
  required BuildContext context,
  required List<String> text_list,
  required Function callback,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Are you sure you want to unlink your account?'),
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                callback();
              },
              child: Text(
                'Yes',
              ),
            ),
          ),
        ],
      );
    },
  );
}
