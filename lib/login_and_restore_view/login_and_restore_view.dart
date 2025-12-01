// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/login_and_restore_view/available_login_providers.dart';
import 'package:xapptor_auth/login_and_restore_view/check_remember_me.dart';
import 'package:xapptor_auth/login_and_restore_view/init_state.dart';
import 'package:xapptor_auth/login_and_restore_view/return_widget.dart';
import 'package:xapptor_translation/model/text_list.dart';
import 'package:xapptor_ui/values/country/country.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

AvailableLoginProviders current_login_providers = AvailableLoginProviders.email_and_phone;
GoogleSignIn? google_signin;

class LoginAndRestoreView extends StatefulWidget {
  AuthFormType auth_form_type;
  final TranslationTextListArray text_list;
  final Function? first_button_action;
  final Function? second_button_action;
  final Function? third_button_action;
  final Function? resend_code_button_action;
  final Color text_color;
  final LinearGradient first_button_color;
  final Color second_button_color;
  final Color third_button_color;
  final String logo_path;
  final double image_border_radius;
  final Color topbar_color;
  final bool has_language_picker;
  final Widget? custom_background;
  final bool outline_border;
  final bool has_back_button;
  final Color? text_field_background_color;
  final TranslationTextListArray? phone_signin_text_list;
  final String apple_signin_client_id;
  final String apple_signin_redirect_url;
  final int source_language_index;
  final bool verify_email;
  AvailableLoginProviders available_login_providers;
  Function? quick_login_callback;
  final bool enable_biometrics;

  /// Background color for the auth container body.
  /// Defaults to Colors.white if not specified.
  final Color? background_color;

  /// Language picker selected text color (for dark themes).
  /// If null, uses text_color.
  final Color? language_picker_selected_text_color;

  /// Back button icon color.
  /// Defaults to Colors.white if not specified.
  final Color? back_button_color;

  /// Optional gradient for form container borders (for elegant dark theme styling).
  /// Takes precedence over outline_border color when provided.
  final LinearGradient? form_border_gradient;

  /// Background color for form containers (if different from text_field_background_color).
  final Color? form_container_background_color;

  /// Gradient for social login button borders (Google, Apple).
  /// Creates elegant gradient-bordered buttons when provided.
  final LinearGradient? social_button_border_gradient;

  /// Text color for secondary/tertiary buttons (e.g., "Forgot Password", "Register").
  /// Defaults to second_button_color and third_button_color if not specified.
  final Color? secondary_text_color;

  /// When true, main button uses gradient border style instead of filled gradient.
  /// Creates an elegant outlined button matching the dark theme aesthetic.
  final bool use_gradient_border_button;

  /// Gradient for email/phone toggle buttons when using gradient style.
  /// When null, uses default solid fill style.
  final LinearGradient? toggle_button_gradient;

  /// Background color for toggle buttons in unselected state.
  final Color? toggle_button_background_color;

  /// Whether to show a language icon in the picker.
  final bool language_picker_show_icon;

  /// Color for the language picker icon.
  final Color? language_picker_icon_color;

  LoginAndRestoreView({
    super.key,
    required this.auth_form_type,
    required this.text_list,
    required this.first_button_action,
    required this.second_button_action,
    required this.third_button_action,
    this.resend_code_button_action,
    required this.text_color,
    required this.first_button_color,
    required this.second_button_color,
    required this.third_button_color,
    required this.logo_path,
    required this.image_border_radius,
    required this.topbar_color,
    required this.has_language_picker,
    required this.custom_background,
    required this.outline_border,
    required this.has_back_button,
    required this.text_field_background_color,
    this.phone_signin_text_list,
    this.apple_signin_client_id = "",
    this.apple_signin_redirect_url = "",
    this.source_language_index = 0,
    this.verify_email = true,
    this.available_login_providers = AvailableLoginProviders.email_and_phone,
    this.quick_login_callback,
    required this.enable_biometrics,
    this.background_color,
    this.language_picker_selected_text_color,
    this.back_button_color,
    this.form_border_gradient,
    this.form_container_background_color,
    this.social_button_border_gradient,
    this.secondary_text_color,
    this.use_gradient_border_button = false,
    this.toggle_button_gradient,
    this.toggle_button_background_color,
    this.language_picker_show_icon = false,
    this.language_picker_icon_color,
  });

  @override
  LoginAndRestoreViewState createState() => LoginAndRestoreViewState();
}

class LoginAndRestoreViewState extends State<LoginAndRestoreView> {
  final GlobalKey<FormState> form_key = GlobalKey<FormState>();

  String email = "";

  bool password_visible = false;
  bool remember_me = false;

  TextEditingController email_input_controller = TextEditingController();
  TextEditingController password_input_controller = TextEditingController();

  late SharedPreferences prefs;

  init_prefs() async {
    prefs = await SharedPreferences.getInstance();
    check_remember_me();
  }

  late TranslationStream translation_stream;
  late TranslationStream translation_stream_phone;
  List<TranslationStream> translation_stream_list = [];

  int source_language_index = 0;

  AuthFormFunctions auth_form_functions = AuthFormFunctions();

  double logo_image_width = 0;

  List<String> google_signin_scopes = [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  Future<GoogleSignInAccount?> handle_google_signin() async {
    try {
      GoogleSignInAccount? google_signin_account = await google_signin?.signIn();
      if (google_signin_account != null) {
        return google_signin_account;
      }
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
    return null;
  }

  @override
  void initState() {
    current_login_providers = widget.available_login_providers;

    if (widget.available_login_providers == AvailableLoginProviders.all ||
        widget.available_login_providers == AvailableLoginProviders.google) {
      google_signin = GoogleSignIn(
        scopes: google_signin_scopes,
      );
    }

    source_language_index = widget.source_language_index;

    if (widget.available_login_providers == AvailableLoginProviders.phone) {
      use_email_signin = false;
    }

    super.initState();
    init_state();
  }

  @override
  void dispose() {
    email_input_controller.dispose();
    password_input_controller.dispose();
    super.dispose();
  }

  bool use_email_signin = true;
  ValueNotifier<bool> verification_code_sent = ValueNotifier(false);

  update_verification_code_sent() {
    verification_code_sent.value = true;
    setState(() {});
  }

  ValueNotifier<Country> current_phone_code = ValueNotifier(countries_list.first);

  @override
  Widget build(BuildContext context) {
    return return_widget();
  }
}
