import 'package:flutter/material.dart';

unlink_alert({
  required BuildContext context,
  required List<String> text_list,
  required String auth_provider_name,
  required Function callback,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:
            Text('Are you sure you want to unlink your $auth_provider_name?'),
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
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
              child: const Text(
                'Yes',
              ),
            ),
          ),
        ],
      );
    },
  );
}
