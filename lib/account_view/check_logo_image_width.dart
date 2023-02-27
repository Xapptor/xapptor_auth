import 'package:flutter/material.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_logic/get_image_size.dart';
import 'package:xapptor_ui/values/ui.dart';

extension CheckLogoImageWidth on AccountViewState {
  check_logo_image_width() async {
    logo_image_width =
        await check_if_image_is_square(image: Image.asset(widget.logo_path))
            ? logo_height(context)
            : logo_width(context);

    setState(() {});
  }
}
