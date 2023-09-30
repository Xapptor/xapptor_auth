import 'package:flutter/material.dart';
import 'package:xapptor_ui/values/ui.dart';

form_section_container({
  required bool outline_border,
  required Color? border_color,
  required Color? background_color,
  IconData? icon,
  Color? icon_color,
  Function? icon_on_press,
  bool add_final_padding = false,
  required Widget child,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 10,
        child: Container(
          padding: EdgeInsets.all(
            outline_padding,
          ),
          decoration: BoxDecoration(
            color: background_color ?? Colors.transparent,
            border: Border.all(
              width: outline_width,
              color: outline_border ? border_color! : background_color!,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(outline_border_radius),
            ),
          ),
          child: child,
        ),
      ),
      add_final_padding ? const Spacer(flex: 1) : Container(),
      icon == null || icon_color == null || icon_on_press == null
          ? Container()
          : Expanded(
              flex: 1,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: Icon(
                  icon,
                  color: icon_color,
                ),
                onPressed: () {
                  icon_on_press();
                },
              ),
            )
    ],
  );
}
