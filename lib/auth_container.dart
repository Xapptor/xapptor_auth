import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:xapptor_ui/widgets/app_version_container.dart';
import 'package:xapptor_ui/widgets/topbar.dart';
import 'package:xapptor_translation/language_picker.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

// Contains User Info Forms.

class AuthContainer extends StatefulWidget {
  final Widget child;
  final Color text_color;
  final Color topbar_color;
  final bool has_language_picker;
  final Widget? custom_background;
  final bool has_back_button;
  final AuthFormType user_info_form_type;
  final List<TranslationStream> translation_stream_list;
  final Function({required int new_source_language_index})
      update_source_language;

  const AuthContainer({
    required this.child,
    required this.text_color,
    required this.topbar_color,
    required this.has_language_picker,
    required this.custom_background,
    required this.has_back_button,
    required this.user_info_form_type,
    required this.translation_stream_list,
    required this.update_source_language,
  });

  @override
  _AuthContainerState createState() => _AuthContainerState();
}

class _AuthContainerState extends State<AuthContainer> {
  final GlobalKey<FormState> login_form_key = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffold_key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async => widget.has_back_button,
        child: Scaffold(
          key: scaffold_key,
          appBar: TopBar(
            context: context,
            background_color: widget.topbar_color,
            has_back_button: widget.has_back_button,
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 20),
                width: 150,
                child: widget.has_language_picker
                    ? LanguagePicker(
                        translation_stream_list: widget.translation_stream_list,
                        language_picker_items_text_color: widget.text_color,
                        update_source_language: widget.update_source_language,
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
                      child: Column(
                        children: [
                          Expanded(
                            flex: 10,
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
                                    child: FractionallySizedBox(
                                      widthFactor: portrait ? 0.9 : 0.3,
                                      child: widget.child,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: is_login(widget.user_info_form_type)
                                ? AppVersionContainer(
                                    text_color: widget.topbar_color,
                                    background_color: Colors.white,
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
