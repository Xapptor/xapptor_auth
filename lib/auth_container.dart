import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:xapptor_ui/widgets/app_version_container.dart';
import 'package:xapptor_ui/widgets/top_and_bottom/topbar.dart';
import 'package:xapptor_translation/language_picker.dart';
import 'package:xapptor_ui/utils/is_portrait.dart';

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
  final Function({required int new_source_language_index}) update_source_language;

  /// Background color for the auth container body.
  /// Defaults to Colors.white if not specified.
  final Color? background_color;

  /// Language picker selected text color (for dark themes).
  /// If null, uses text_color.
  final Color? language_picker_selected_text_color;

  /// Back button icon color.
  /// Defaults to Colors.white if not specified.
  final Color? back_button_color;

  /// Whether to show a language icon in the picker.
  final bool language_picker_show_icon;

  /// Color for the language picker icon.
  final Color? language_picker_icon_color;

  const AuthContainer({
    super.key,
    required this.child,
    required this.text_color,
    required this.topbar_color,
    required this.has_language_picker,
    required this.custom_background,
    required this.has_back_button,
    required this.user_info_form_type,
    required this.translation_stream_list,
    required this.update_source_language,
    this.background_color,
    this.language_picker_selected_text_color,
    this.back_button_color,
    this.language_picker_show_icon = false,
    this.language_picker_icon_color,
  });

  @override
  State<AuthContainer> createState() => _AuthContainerState();
}

class _AuthContainerState extends State<AuthContainer> {
  final GlobalKey<FormState> login_form_key = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffold_key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);

    // Use provided background color or default to white
    final Color bg_color = widget.background_color ?? Colors.white;
    final Color back_btn_color = widget.back_button_color ?? Colors.white;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: PopScope(
        canPop: widget.has_back_button,
        child: Scaffold(
          key: scaffold_key,
          backgroundColor: bg_color,
          appBar: TopBar(
            context: context,
            background_color: widget.topbar_color,
            has_back_button: widget.has_back_button,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 20),
                width: widget.language_picker_show_icon ? 170 : 150,
                child: widget.has_language_picker
                    ? LanguagePicker(
                        translation_stream_list: widget.translation_stream_list,
                        language_picker_items_text_color: widget.text_color,
                        selected_text_color: widget.language_picker_selected_text_color ?? widget.text_color,
                        update_source_language: widget.update_source_language,
                        show_icon: widget.language_picker_show_icon,
                        icon_color: widget.language_picker_icon_color,
                      )
                    : null,
              ),
            ],
            custom_leading: widget.has_back_button
                ? IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      FontAwesomeIcons.angleLeft,
                      color: back_btn_color,
                    ),
                  )
                : null,
            logo_path: null,
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            color: bg_color,
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
                                      color: bg_color,
                                    ),
                                PointerInterceptor(
                                  child: Container(
                                    color: widget.custom_background != null ? Colors.transparent : bg_color,
                                    child: FractionallySizedBox(
                                      widthFactor: portrait ? 0.9 : 0.3,
                                      child: widget.child,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (is_login(widget.user_info_form_type))
                            Expanded(
                              flex: 1,
                              child: AppVersionContainer(
                                text_color: widget.topbar_color,
                                background_color: bg_color,
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
        ),
      ),
    );
  }
}
