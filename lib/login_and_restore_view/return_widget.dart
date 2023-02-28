import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_container.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/get_auth_view_logo.dart';
import 'package:xapptor_auth/login_and_restore_view/login_and_restore_view.dart';
import 'package:xapptor_auth/login_and_restore_view/quick_login_widgets.dart';
import 'package:xapptor_auth/login_and_restore_view/update_source_language.dart';
import 'package:xapptor_ui/values/ui.dart';

extension ReturnWidget on LoginAndRestoreViewState {
  Widget return_widget() {
    Widget return_widget = Container();

    if (is_quick_login(widget.auth_form_type)) {
      return_widget = quick_login_widgets();
    } else {
      return_widget = AuthContainer(
        translation_stream_list: translation_stream_list,
        user_info_form_type: AuthFormType.login,
        custom_background: widget.custom_background,
        has_language_picker: widget.has_language_picker,
        topbar_color: widget.topbar_color,
        text_color: widget.text_color,
        has_back_button: widget.has_back_button,
        update_source_language: update_source_language,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: sized_box_space,
            ),
            get_auth_view_logo(
              context: context,
              logo_path: widget.logo_path,
              logo_image_width: logo_image_width,
              image_border_radius: widget.image_border_radius,
            ),
            is_login(widget.auth_form_type)
                ? Container()
                : Column(
                    children: [
                      SizedBox(
                        height: sized_box_space,
                      ),
                      Text(
                        widget.text_list.get(source_language_index)[0],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.text_color,
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: sized_box_space,
            ),
            quick_login_widgets(),
          ],
        ),
      );
    }
    return return_widget;
  }
}
