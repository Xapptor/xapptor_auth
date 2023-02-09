import 'package:flutter/material.dart';
import 'package:xapptor_ui/values/ui.dart';

form_section_container({
  required Widget child,
  required bool outline_border,
  required Color? border_color,
  required Color? background_color,
}) {
  return Container(
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
  );
}
