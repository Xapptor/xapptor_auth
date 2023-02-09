import 'package:flutter/widgets.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:xapptor_ui/widgets/webview/webview.dart';

Widget get_auth_view_logo({
  required BuildContext context,
  required String logo_path,
  required double logo_image_width,
  required double image_border_radius,
}) {
  return Container(
    //color: Colors.lightGreen,
    child: logo_path.contains("http")
        ? Container(
            height: logo_height(context),
            width: logo_image_width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                image_border_radius,
              ),
            ),
            child: Webview(
              id: "20",
              src: logo_path,
            ),
          )
        : Container(
            height: logo_height(context),
            width: logo_image_width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                image_border_radius,
              ),
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage(
                  logo_path,
                ),
              ),
            ),
          ),
  );
}
