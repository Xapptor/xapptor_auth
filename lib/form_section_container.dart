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
  /// Optional gradient for the border (takes precedence over border_color)
  LinearGradient? border_gradient,
  /// Width of gradient border (default 1.5)
  double gradient_border_width = 1.5,
}) {
  // Build the container content
  Widget containerContent = Container(
    padding: const EdgeInsets.all(outline_padding),
    decoration: BoxDecoration(
      color: background_color ?? Colors.transparent,
      border: border_gradient == null
          ? Border.all(
              width: outline_width,
              color: outline_border ? border_color! : (background_color ?? Colors.transparent),
            )
          : null,
      borderRadius: const BorderRadius.all(
        Radius.circular(outline_border_radius),
      ),
    ),
    child: child,
  );

  // If gradient border is provided, wrap with gradient container
  Widget finalContainer;
  if (border_gradient != null && outline_border) {
    finalContainer = Container(
      decoration: BoxDecoration(
        gradient: border_gradient,
        borderRadius: const BorderRadius.all(
          Radius.circular(outline_border_radius),
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(gradient_border_width),
        decoration: BoxDecoration(
          color: background_color ?? Colors.transparent,
          borderRadius: BorderRadius.all(
            Radius.circular(outline_border_radius - gradient_border_width),
          ),
        ),
        padding: const EdgeInsets.all(outline_padding),
        child: child,
      ),
    );
  } else {
    finalContainer = containerContent;
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 10,
        child: finalContainer,
      ),
      if (add_final_padding) const Spacer(flex: 1),
      if (icon != null && icon_color != null && icon_on_press != null)
        Expanded(
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
        ),
    ],
  );
}
