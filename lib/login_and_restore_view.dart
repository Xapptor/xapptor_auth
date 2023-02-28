import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:xapptor_auth/auth_form_functions/login.dart';
import 'package:xapptor_auth/auth_form_functions/login_phone_number.dart';
import 'package:xapptor_auth/auth_form_functions/restore_password.dart';
import 'package:xapptor_auth/auth_form_functions/send_verification_code.dart';
import 'package:xapptor_auth/get_auth_view_logo.dart';
import 'package:xapptor_logic/form_field_validators.dart';
import 'package:xapptor_logic/get_image_size.dart';
import 'package:xapptor_logic/sha256_of_string.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_translation/model/text_list.dart';
import 'package:xapptor_ui/values/country_phone_codes.dart';
import 'package:xapptor_ui/widgets/country_phone_codes_picker.dart';
import 'package:xapptor_ui/widgets/custom_card.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'check_if_app_enabled.dart';
import 'form_section_container.dart';
import 'signin_with_apple.dart';
import 'signin_with_google.dart';
import 'auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:flutter/material.dart';
import 'auth_form_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';
import 'auth_container.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum AvailableLoginProviders {
  all,
  email,
  phone,
  email_and_phone,
  google,
  apple,
}

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

  LoginAndRestoreView({
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
    this.image_border_radius = 0,
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
    check_remember_me();
  }

  check_remember_me() async {
    if (use_email_signin) {
      if (prefs.getString("email") != null) {
        email_input_controller.text = prefs.getString("email")!;
        remember_me = true;
        setState(() {});
      }
    } else {
      if (prefs.getString("phone_number") != null ||
          prefs.getString("phone_code") != null) {
        if (prefs.getString("phone_number") != null) {
          email_input_controller.text = prefs.getString("phone_number")!;
        }
        if (prefs.getString("phone_code") != null) {
          current_phone_code.value = country_phone_code_list.firstWhere(
            (element) => element.dial_code == prefs.getString("phone_code"),
            orElse: () => country_phone_code_list[0],
          );
        }
      }
      remember_me = true;
      setState(() {});
    }
  }

  late TranslationStream translation_stream;
  late TranslationStream translation_stream_phone;
  List<TranslationStream> translation_stream_list = [];

  int source_language_index = 0;

  AuthFormFunctions auth_form_functions = AuthFormFunctions();

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
    if (widget.available_login_providers == AvailableLoginProviders.phone)
      use_email_signin = false;

    super.initState();

    check_if_app_enabled();

    if (!is_quick_login(widget.auth_form_type)) {
      check_login();
    }
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
    verification_code_sent.value = true;
    setState(() {});
  }

  ValueNotifier<CountryPhoneCode> current_phone_code =
      ValueNotifier(country_phone_code_list.first);

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);
    double screen_width = MediaQuery.of(context).size.width;

    String main_button_text = '';

    if (widget.phone_signin_text_list != null && !use_email_signin) {
      main_button_text = widget.phone_signin_text_list!
          .get(source_language_index)[!verification_code_sent.value ? 2 : 4];
    } else {
      main_button_text = widget.text_list.get(source_language_index)[
          widget.text_list.get(source_language_index).length -
              (is_login(widget.auth_form_type) ||
                      is_quick_login(widget.auth_form_type)
                  ? 3
                  : 1)];
    }

    int current_phone_code_length =
        current_phone_code.value.name.split(',').first.length +
            current_phone_code.value.dial_code.length;

    int current_phone_code_flex = 1;

    if (current_phone_code_length > 0 && current_phone_code_length <= 12) {
      current_phone_code_flex = (current_phone_code_length * 1.0).floor();
      //
    } else if (current_phone_code_length > 12 &&
        current_phone_code_length <= 25) {
      current_phone_code_flex = (current_phone_code_length * 0.7).floor();
      //
    } else if (current_phone_code_length >= 26) {
      current_phone_code_flex = (current_phone_code_length * 0.4).floor();
    }

    Widget quick_login_widgets = Form(
      key: form_key,
      child: Column(
        mainAxisSize: is_quick_login(widget.auth_form_type)
            ? MainAxisSize.min
            : MainAxisSize.max,
        children: [
          (is_login(widget.auth_form_type) ||
                      is_quick_login(widget.auth_form_type)) &&
                  widget.phone_signin_text_list != null &&
                  (widget.available_login_providers ==
                          AvailableLoginProviders.all ||
                      widget.available_login_providers ==
                          AvailableLoginProviders.email_and_phone)
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: use_email_signin
                                ? widget.text_color
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              use_email_signin = !use_email_signin;
                              email_input_controller.clear();
                              password_input_controller.clear();
                              check_remember_me();
                              setState(() {});
                            },
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: use_email_signin
                                  ? Colors.white
                                  : widget.text_color,
                              size: 30,
                            ),
                          ),
                        ),
                        Container(
                          height: 38,
                          width: 38,
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: !use_email_signin
                                ? widget.text_color
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              use_email_signin = !use_email_signin;
                              email_input_controller.clear();
                              password_input_controller.clear();
                              check_remember_me();
                              setState(() {});
                            },
                            icon: Icon(
                              FontAwesomeIcons.commentSms,
                              color: !use_email_signin
                                  ? Colors.white
                                  : widget.text_color,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: sized_box_space * 0.7,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    use_email_signin
                        ? Container()
                        : Expanded(
                            flex: current_phone_code_flex,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              child: CountryPhoneCodesPicker(
                                current_phone_code: current_phone_code,
                                text_color: widget.text_color,
                                setState: setState,
                              ),
                            ),
                          ),
                    use_email_signin ? Container() : Spacer(flex: 1),
                    Expanded(
                      flex: 12,
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          on_pressed_first_button();
                        },
                        style: TextStyle(color: widget.text_color),
                        decoration: InputDecoration(
                          labelText: widget.phone_signin_text_list != null &&
                                  !use_email_signin
                              ? widget.phone_signin_text_list!
                                  .get(source_language_index)[0]
                              : widget.text_list.get(source_language_index)[
                                  is_login(widget.auth_form_type) ||
                                          is_quick_login(widget.auth_form_type)
                                      ? 0
                                      : 1],
                          labelStyle: TextStyle(
                            color: widget.text_color,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.text_color,
                            ),
                          ),
                          errorMaxLines: 2,
                        ),
                        controller: email_input_controller,
                        inputFormatters: use_email_signin
                            ? null
                            : [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => FormFieldValidators(
                          value: value!,
                          type: use_email_signin
                              ? FormFieldValidatorsType.email
                              : FormFieldValidatorsType.phone,
                        ).validate(),
                        keyboardType: use_email_signin
                            ? TextInputType.emailAddress
                            : TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: sized_box_space,
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            reverseDuration: Duration(milliseconds: 200),
            child: (!is_login(widget.auth_form_type) &&
                        !is_quick_login(widget.auth_form_type)) ||
                    (widget.phone_signin_text_list != null &&
                        !use_email_signin &&
                        !verification_code_sent.value)
                ? Container(
                    key: ValueKey<int>(1),
                  )
                : Container(
                    key: ValueKey<int>(0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: sized_box_space,
                        ),
                        form_section_container(
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
                                  type: use_email_signin
                                      ? FormFieldValidatorsType.password
                                      : FormFieldValidatorsType.sms_code,
                                ).validate(),
                                obscureText:
                                    use_email_signin && !_password_visible,
                                keyboardType: use_email_signin
                                    ? TextInputType.text
                                    : TextInputType.number,
                                inputFormatters: use_email_signin
                                    ? null
                                    : <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
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
                      ],
                    ),
                  ),
          ),
          !is_login(widget.auth_form_type)
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    !use_email_signin && !verification_code_sent.value
                        ? Container()
                        : SizedBox(
                            height: sized_box_space,
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        !use_email_signin && !verification_code_sent.value
                            ? Container()
                            : TextButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width,
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (use_email_signin) {
                                    if (widget.second_button_action != null) {
                                      widget.second_button_action!();
                                    }
                                  } else {
                                    if (widget.resend_code_button_action !=
                                        null) {
                                      widget.resend_code_button_action!();
                                    } else {
                                      auth_form_functions
                                          .send_verification_code(
                                        context: context,
                                        phone_input_controller:
                                            TextEditingController(
                                          text: current_phone_code
                                                  .value.dial_code +
                                              ' ' +
                                              email_input_controller.text,
                                        ),
                                        code_input_controller:
                                            password_input_controller,
                                        prefs: prefs,
                                        update_verification_code_sent:
                                            update_verification_code_sent,
                                        remember_me: remember_me,
                                        callback: null,
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  !use_email_signin &&
                                          widget.phone_signin_text_list != null
                                      ? widget.phone_signin_text_list!
                                          .get(source_language_index)[widget
                                              .phone_signin_text_list!
                                              .get(source_language_index)
                                              .length -
                                          2]
                                      : widget.text_list
                                          .get(source_language_index)[widget
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
                        !use_email_signin
                            ? Container()
                            : TextButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width,
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (widget.third_button_action != null) {
                                    widget.third_button_action!();
                                  }
                                },
                                child: Text(
                                  widget.text_list
                                      .get(source_language_index)[5],
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
                      height: sized_box_space,
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
          (widget.available_login_providers == AvailableLoginProviders.all ||
                  widget.available_login_providers ==
                      AvailableLoginProviders.apple ||
                  widget.available_login_providers ==
                      AvailableLoginProviders.google)
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
                    widget.available_login_providers ==
                            AvailableLoginProviders.google
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
                    widget.available_login_providers ==
                            AvailableLoginProviders.apple
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
    );

    Widget return_widget = Container();

    if (is_quick_login(widget.auth_form_type)) {
      return_widget = quick_login_widgets;
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
            quick_login_widgets,
          ],
        ),
      );
    }
    return return_widget;
  }

  on_pressed_first_button() {
    if (widget.first_button_action == null) {
      if (is_login(widget.auth_form_type) ||
          is_quick_login(widget.auth_form_type)) {
        if (use_email_signin) {
          List<TextEditingController> inputControllers = [
            email_input_controller,
            password_input_controller,
          ];

          auth_form_functions.login(
            context: context,
            remember_me: remember_me,
            form_key: form_key,
            input_controllers: inputControllers,
            prefs: prefs,
            persistence: Persistence.LOCAL,
            verify_email: widget.verify_email,
          );
        } else {
          TextEditingController phone_input_controller = TextEditingController(
            text: current_phone_code.value.dial_code +
                ' ' +
                email_input_controller.text,
          );

          List<TextEditingController> input_controllers = [
            phone_input_controller,
            password_input_controller,
          ];

          if (form_key.currentState!.validate()) {
            auth_form_functions.login_phone_number(
              context: context,
              input_controllers: input_controllers,
              prefs: prefs,
              verification_code_sent: verification_code_sent,
              update_verification_code_sent: update_verification_code_sent,
              persistence: Persistence.LOCAL,
              remember_me: remember_me,
              callback: widget.quick_login_callback,
            );
          }
        }
      } else {
        AuthFormFunctions().restore_password(
          context: context,
          form_key: form_key,
          email_input_controller: email_input_controller,
        );
      }
    } else {
      widget.first_button_action!();
    }
  }
}
