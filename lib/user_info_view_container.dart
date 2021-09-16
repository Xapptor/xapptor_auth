import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:xapptor_auth/user_info_form_type.dart';
import 'package:xapptor_translation/translate.dart';
import 'package:xapptor_ui/widgets/made_with_container.dart';
import 'package:xapptor_ui/widgets/topbar.dart';
import 'package:xapptor_translation/language_picker.dart';
import 'package:xapptor_logic/is_portrait.dart';

class UserInfoViewContainer extends StatefulWidget {
  const UserInfoViewContainer({
    required this.child,
    required this.text_color,
    required this.topbar_color,
    required this.has_language_picker,
    required this.custom_background,
    required this.has_back_button,
    required this.user_info_form_type,
    required this.translation_stream_list,
    this.app_version,
  });

  final Widget child;
  final Color text_color;
  final Color topbar_color;
  final bool has_language_picker;
  final Widget? custom_background;
  final bool has_back_button;
  final UserInfoFormType user_info_form_type;
  final List<TranslationStream> translation_stream_list;
  final String? app_version;

  @override
  _UserInfoViewContainerState createState() => _UserInfoViewContainerState();
}

class _UserInfoViewContainerState extends State<UserInfoViewContainer> {
  final GlobalKey<FormState> login_form_key = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffold_key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);

    return WillPopScope(
      onWillPop: () async => widget.has_back_button,
      child: Scaffold(
        key: scaffold_key,
        appBar: TopBar(
          background_color: widget.topbar_color,
          has_back_button: widget.has_back_button,
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 20),
              width: portrait ? 100 : 200,
              child: widget.has_language_picker
                  ? LanguagePicker(
                      translation_stream_list: widget.translation_stream_list,
                      language_picker_items_text_color: widget.text_color,
                    )
                  : Container(),
            ),
          ],
          custom_leading: null,
          logo_path: null,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: LayoutBuilder(
                  builder: (
                    BuildContext context,
                    BoxConstraints viewport_constraints,
                  ) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewport_constraints.minHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              widget.custom_background ??
                                  Container(
                                    color: Colors.white,
                                  ),
                              PointerInterceptor(
                                child: Container(
                                  color: widget.custom_background != null
                                      ? Colors.transparent
                                      : Colors.white,
                                  child: widget.child,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              is_login(widget.user_info_form_type) && widget.app_version != null
                  ? MadeWithContainer(
                      text_color: Colors.white,
                      background_color: widget.topbar_color,
                      app_version: widget.app_version!,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
