import 'package:flutter/material.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:xapptor_ui/widgets/webview/webview.dart';

Widget get_auth_view_logo({
  required BuildContext context,
  required String logo_path,
  required double logo_image_width,
  required double image_border_radius,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(image_border_radius),
    child: SizedBox(
      height: logo_height(context),
      width: logo_image_width,
      child: logo_path.contains("http")
          ? Webview(
              id: "20",
              src: logo_path,
            )
          : Image.asset(
              logo_path,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
            ),
    ),
  );
}
