import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xapptor_logic/get_image_size.dart';
import 'package:xapptor_ui/values/ui.dart';

check_logo_image_width({
  required BuildContext context,
  required String logo_path,
  required Function(double logo_image_width) callback,
}) async {
  Timer(const Duration(milliseconds: 100), () async {
    if (context.mounted) {
      double height_value = logo_height(context);
      double width_value = logo_width(context);
      Image image = Image.asset(logo_path);
      bool image_is_square = await check_if_image_is_square(image: image);
      callback(image_is_square ? height_value : width_value);
    }
  });
}
