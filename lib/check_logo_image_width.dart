import 'package:flutter/material.dart';
import 'package:xapptor_logic/get_image_size.dart';
import 'package:xapptor_ui/values/ui.dart';

check_logo_image_width({
  required BuildContext context,
  required String logo_path,
  required Function(double logo_image_width) callback,
}) async {
  double logo_image_width =
      await check_if_image_is_square(image: Image.asset(logo_path))
          ? logo_height(context)
          : logo_width(context);
  callback(logo_image_width);
}
