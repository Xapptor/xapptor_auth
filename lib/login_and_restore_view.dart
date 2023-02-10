import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:xapptor_auth/get_auth_view_logo.dart';
import 'package:xapptor_logic/form_field_validators.dart';
import 'package:xapptor_logic/get_image_size.dart';
import 'package:xapptor_logic/sha256_of_string.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_translation/model/text_list.dart';
import 'package:xapptor_ui/widgets/custom_card.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'check_if_app_enabled.dart';
import 'form_section_container.dart';
import 'signin_with_apple.dart';
import 'signin_with_google.dart';
import 'auth_form_functions.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:flutter/material.dart';
import 'auth_form_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';
import 'auth_container.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginAndRestoreView extends StatefulWidget {
  final bool is_login;
  final TranslationTextListArray text_list;
  final Function? first_button_action;
  final Function? second_button_action;
  final Function? third_button_action;
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
  final bool? edit_icon_use_text_field_background_color;
  final bool enable_google_signin;
  final bool enable_apple_signin;
  final TranslationTextListArray? phone_signin_text_list;
  final String apple_signin_client_id;
  final String apple_signin_redirect_url;
  final int source_language_index;
  final bool verify_email;

  const LoginAndRestoreView({
    required this.is_login,
    required this.text_list,
    required this.first_button_action,
    required this.second_button_action,
    required this.third_button_action,
    required this.text_color,
    required this.first_button_color,
    required this.second_button_color,
    required this.third_button_color,
    required this.logo_path,
    this.image_border_radius = 0,
    required this.topbar_color,
    required this.has_language_picker,
    required this.custom_background,
    required this.outline_border,
    required this.has_back_button,
    required this.text_field_background_color,
    this.edit_icon_use_text_field_background_color,
    this.enable_google_signin = false,
    this.enable_apple_signin = false,
    this.phone_signin_text_list,
    this.apple_signin_client_id = "",
    this.apple_signin_redirect_url = "",
    this.source_language_index = 0,
    this.verify_email = true,
  });

  @override
  _LoginAndRestoreViewState createState() => _LoginAndRestoreViewState();
}

class _LoginAndRestoreViewState extends State<LoginAndRestoreView> {
  final GlobalKey<FormState> form_key = GlobalKey<FormState>();

  String email = "";

  bool _password_visible = false;
  bool remember_me = false;

  TextEditingController email_input_controller = TextEditingController();
  TextEditingController password_input_controller = TextEditingController();

  late SharedPreferences prefs;

  init_prefs() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getString("email") != null) {
      email_input_controller.text = prefs.getString("email")!;
      remember_me = true;
      setState(() {});
    }
  }

  late TranslationStream translation_stream;
  late TranslationStream translation_stream_phone;
  List<TranslationStream> translation_stream_list = [];

  int source_language_index = 0;

  update_source_language({
    required int new_source_language_index,
  }) {
    source_language_index = new_source_language_index;
    setState(() {});
  }

  update_text_list({
    required int index,
    required String new_text,
    required int list_index,
  }) {
    if (list_index == 0) {
      widget.text_list.get(source_language_index)[index] = new_text;
    } else if (list_index == 1) {
      widget.phone_signin_text_list!.get(source_language_index)[index] =
          new_text;
    }
    setState(() {});
  }

  check_login() async {
    Timer(Duration(milliseconds: 300), () async {
      if (FirebaseAuth.instance.currentUser != null) {
        print("User is logged in");
        open_screen("home");
      } else {
        var google_signin_account = await _google_signin.currentUser;
        if (google_signin_account != null) {
          signin_with_google(google_signin_account);
        } else {
          print("User is not sign");
          check_logo_image_width();
        }
      }
    });
  }

  double logo_image_width = 0;

  check_logo_image_width() async {
    logo_image_width =
        await check_if_image_is_square(image: Image.asset(widget.logo_path))
            ? logo_height(context)
            : logo_width(context);

    setState(() {});
  }

  GoogleSignIn _google_signin = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<GoogleSignInAccount?> handle_google_signin() async {
    try {
      GoogleSignInAccount? google_signin_account =
          await _google_signin.signIn();
      if (google_signin_account != null) {
        return google_signin_account;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  @override
  void initState() {
    source_language_index = widget.source_language_index;
    super.initState();

    check_if_app_enabled();
    check_login();
    init_prefs();

    translation_stream = TranslationStream(
      translation_text_list_array: widget.text_list,
      update_text_list_function: update_text_list,
      list_index: 0,
      source_language_index: source_language_index,
    );

    if (widget.phone_signin_text_list != null) {
      translation_stream_phone = TranslationStream(
        translation_text_list_array: widget.phone_signin_text_list!,
        update_text_list_function: update_text_list,
        list_index: 1,
        source_language_index: source_language_index,
      );

      translation_stream_list = [
        translation_stream,
        translation_stream_phone,
      ];
    } else {
      translation_stream_list = [
        translation_stream,
      ];
    }
  }

  @override
  void dispose() {
    email_input_controller.dispose();
    password_input_controller.dispose();
    super.dispose();
  }

  ShapeBorder third_party_signin_method_shape(double screen_width) {
    return RoundedRectangleBorder(
      side: BorderSide(
        color: widget.text_color,
      ),
      borderRadius: BorderRadius.circular(screen_width),
    );
  }

  bool use_email_signin = true;
  ValueNotifier<bool> verification_code_sent = ValueNotifier(false);

  update_verification_code_sent() {
    verification_code_sent.value = !verification_code_sent.value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);
    double screen_width = MediaQuery.of(context).size.width;

    String main_button_text = '';

    if (widget.phone_signin_text_list != null && !use_email_signin) {
      main_button_text = widget.phone_signin_text_list!
          .get(source_language_index)[!verification_code_sent.value ? 2 : 3];
    } else {
      main_button_text = widget.text_list.get(source_language_index)[
          widget.text_list.get(source_language_index).length -
              (widget.is_login ? 3 : 1)];
    }

    return AuthContainer(
      translation_stream_list: translation_stream_list,
      user_info_form_type: AuthFormType.login,
      custom_background: widget.custom_background,
      has_language_picker: widget.has_language_picker,
      topbar_color: widget.topbar_color,
      text_color: widget.text_color,
      has_back_button: widget.has_back_button,
      update_source_language: update_source_language,
      child: Form(
        key: form_key,
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
            widget.is_login
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
            widget.is_login && widget.phone_signin_text_list != null
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: use_email_signin
                                  ? widget.text_color
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {
                                use_email_signin = !use_email_signin;
                                setState(() {});
                              },
                              icon: Icon(
                                FontAwesomeIcons.envelope,
                                color: use_email_signin
                                    ? Colors.white
                                    : widget.text_color,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: !use_email_signin
                                  ? widget.text_color
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {
                                use_email_signin = !use_email_signin;
                                setState(() {});
                              },
                              icon: Icon(
                                FontAwesomeIcons.mobile,
                                color: !use_email_signin
                                    ? Colors.white
                                    : widget.text_color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: sized_box_space,
                      ),
                    ],
                  )
                : Container(),
            form_section_container(
              outline_border: widget.outline_border,
              border_color: widget.text_color,
              background_color: widget.text_field_background_color,
              child: Column(
                children: [
                  TextFormField(
                    style: TextStyle(color: widget.text_color),
                    decoration: InputDecoration(
                      labelText: widget.phone_signin_text_list != null &&
                              !use_email_signin
                          ? widget.phone_signin_text_list!
                              .get(source_language_index)[0]
                          : widget.text_list.get(
                              source_language_index)[widget.is_login ? 0 : 1],
                      labelStyle: TextStyle(
                        color: widget.text_color,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: widget.text_color,
                        ),
                      ),
                    ),
                    controller: email_input_controller,
                    validator: (value) => FormFieldValidators(
                      value: value!,
                      type: use_email_signin
                          ? FormFieldValidatorsType.email
                          : FormFieldValidatorsType.phone,
                    ).validate(),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: sized_box_space,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: sized_box_space,
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              reverseDuration: Duration(milliseconds: 200),
              child: !widget.is_login ||
                      (widget.phone_signin_text_list != null &&
                          !use_email_signin &&
                          !verification_code_sent.value)
                  ? Container(
                      key: ValueKey<int>(1),
                    )
                  : Container(
                      key: ValueKey<int>(0),
                      child: form_section_container(
                        outline_border: widget.outline_border,
                        border_color: widget.text_color,
                        background_color: widget.text_field_background_color,
                        child: Column(
                          children: [
                            TextFormField(
                              onFieldSubmitted: (value) {
                                on_pressed_first_button();
                              },
                              style: TextStyle(color: widget.text_color),
                              decoration: InputDecoration(
                                labelText:
                                    widget.phone_signin_text_list != null &&
                                            !use_email_signin
                                        ? widget.phone_signin_text_list!
                                            .get(source_language_index)[1]
                                        : widget.text_list
                                            .get(source_language_index)[1],
                                labelStyle: TextStyle(
                                  color: widget.text_color,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: widget.text_color,
                                  ),
                                ),
                                suffixIcon: use_email_signin
                                    ? IconButton(
                                        icon: Icon(
                                          _password_visible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: widget.text_color,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _password_visible =
                                                !_password_visible;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              controller: password_input_controller,
                              validator: (value) => FormFieldValidators(
                                value: value!,
                                type: FormFieldValidatorsType.password,
                              ).validate(),
                              obscureText:
                                  use_email_signin && !_password_visible,
                            ),
                            SizedBox(
                              height: sized_box_space,
                            ),
                            TextButton(
                              onPressed: () {
                                remember_me = !remember_me;
                                setState(() {});
                              },
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      remember_me
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: widget.text_color,
                                    ),
                                    margin: EdgeInsets.only(
                                      right: 10,
                                    ),
                                  ),
                                  Text(
                                    widget.text_list
                                        .get(source_language_index)[2],
                                    style: TextStyle(
                                      color: widget.text_color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            !widget.is_login
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: portrait ? 0 : (sized_box_space),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              if (widget.second_button_action != null) {
                                widget.second_button_action!();
                              }
                            },
                            child: Text(
                              widget.text_list.get(source_language_index)[widget
                                      .text_list
                                      .get(source_language_index)
                                      .length -
                                  2],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: widget.second_button_color,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (widget.third_button_action != null) {
                                widget.third_button_action!();
                              }
                            },
                            child: Text(
                              widget.text_list.get(source_language_index)[5],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: widget.third_button_color,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: portrait ? 0 : (sized_box_space),
                      ),
                    ],
                  ),
            Container(
              height: 50,
              width: screen_width / (portrait ? 2 : 8),
              child: CustomCard(
                border_radius: screen_width,
                elevation: (widget.first_button_color.colors.first ==
                            Colors.transparent &&
                        widget.first_button_color.colors.last ==
                            Colors.transparent)
                    ? 0
                    : 7,
                on_pressed: on_pressed_first_button,
                linear_gradient: widget.first_button_color,
                splash_color: widget.second_button_color.withOpacity(0.2),
                child: Center(
                  child: Text(
                    main_button_text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: (widget.first_button_color.colors.first ==
                                  Colors.transparent &&
                              widget.first_button_color.colors.last ==
                                  Colors.transparent)
                          ? widget.second_button_color
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: sized_box_space,
            ),
            (widget.enable_google_signin || widget.enable_apple_signin)
                ? Column(
                    children: [
                      Text(
                        "Or",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.text_color,
                        ),
                      ),
                      SizedBox(
                        height: sized_box_space,
                      ),
                      widget.enable_google_signin
                          ? SignInButton(
                              Buttons.google,
                              shape:
                                  third_party_signin_method_shape(screen_width),
                              onPressed: () async {
                                GoogleSignInAccount? google_signin_account =
                                    await handle_google_signin();
                                if (google_signin_account != null) {
                                  signin_with_google(google_signin_account);
                                }
                              },
                            )
                          : Container(),
                      SizedBox(
                        height: sized_box_space,
                      ),
                      widget.enable_apple_signin
                          ? SignInButton(
                              Buttons.apple,
                              shape:
                                  third_party_signin_method_shape(screen_width),
                              onPressed: () async {
                                final raw_nonce = generateNonce();
                                final nonce = sha256_of_string(raw_nonce);

                                AuthorizationCredentialAppleID credential =
                                    await SignInWithApple.getAppleIDCredential(
                                  webAuthenticationOptions:
                                      WebAuthenticationOptions(
                                    clientId: widget.apple_signin_client_id,
                                    redirectUri: Uri.parse(
                                        widget.apple_signin_redirect_url),
                                  ),
                                  scopes: [
                                    AppleIDAuthorizationScopes.email,
                                    AppleIDAuthorizationScopes.fullName,
                                  ],
                                  //nonce: nonce,
                                );

                                signin_with_apple(
                                  credential,
                                  raw_nonce,
                                );
                              },
                            )
                          : Container(),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  AuthFormFunctions auth_form_functions = AuthFormFunctions();

  on_pressed_first_button() {
    if (widget.first_button_action == null) {
      if (widget.is_login) {
        List<TextEditingController> inputControllers = [
          email_input_controller,
          password_input_controller,
        ];

        if (use_email_signin) {
          auth_form_functions.login(
            context: context,
            remember_me: remember_me,
            login_form_key: form_key,
            input_controllers: inputControllers,
            prefs: prefs,
            persistence: Persistence.LOCAL,
            verify_email: widget.verify_email,
          );
        } else {
          auth_form_functions.login_phone_number(
            context: context,
            login_form_key: form_key,
            input_controllers: inputControllers,
            prefs: prefs,
            verification_code_sent: verification_code_sent,
            update_verification_code_sent: update_verification_code_sent,
            persistence: Persistence.LOCAL,
          );
        }
      } else {
        AuthFormFunctions().restore_password(
          context: context,
          restore_password_form_key: form_key,
          email_input_controller: email_input_controller,
        );
      }
    } else {
      widget.first_button_action!();
    }
  }
}
