import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_auth/account_view/dispose_controllers.dart';
import 'package:xapptor_auth/account_view/email_form_section.dart';
import 'package:xapptor_auth/account_view/link_email_button.dart';
import 'package:xapptor_auth/account_view/link_phone_button.dart';
import 'package:xapptor_auth/account_view/main_button.dart';
import 'package:xapptor_auth/account_view/password_form_section.dart';
import 'package:xapptor_auth/account_view/second_button.dart';
import 'package:xapptor_auth/account_view/unlink_email_button.dart';
import 'package:xapptor_auth/account_view/unlink_phone_button.dart';
import 'package:xapptor_auth/account_view/update_source_language.dart';
import 'package:xapptor_auth/account_view/user_id_button.dart';
import 'package:xapptor_auth/account_view/user_info_form_section.dart';
import 'package:xapptor_auth/account_view/init_state.dart';
import 'package:xapptor_auth/auth_container.dart';
import 'package:xapptor_auth/auth_form_type.dart';
import 'package:xapptor_auth/check_provider.dart';
import 'package:xapptor_auth/get_auth_view_logo.dart';
import 'package:xapptor_auth/get_over_18_date.dart';
import 'package:xapptor_translation/model/text_list.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountView extends StatefulWidget {
  final TranslationTextListArray text_list;
  final RichText tc_and_pp_text;
  final Function? first_button_action;
  final Function? second_button_action;
  final TranslationTextListArray gender_values;
  final List<String>? country_values;
  final Color text_color;
  final LinearGradient first_button_color;
  final Color second_button_color;
  final String logo_path;
  final double image_border_radius;
  final Color topbar_color;
  final bool has_language_picker;
  final Widget? custom_background;
  final AuthFormType auth_form_type;
  final bool outline_border;
  final bool has_back_button;
  final Color? text_field_background_color;
  final bool? edit_icon_use_text_field_background_color;
  final int source_language_index;

  const AccountView({
    super.key,
    required this.text_list,
    required this.tc_and_pp_text,
    required this.first_button_action,
    required this.second_button_action,
    required this.gender_values,
    required this.country_values,
    required this.text_color,
    required this.first_button_color,
    required this.second_button_color,
    required this.logo_path,
    required this.image_border_radius,
    required this.topbar_color,
    required this.has_language_picker,
    required this.custom_background,
    required this.auth_form_type,
    required this.outline_border,
    required this.has_back_button,
    required this.text_field_background_color,
    this.edit_icon_use_text_field_background_color,
    this.source_language_index = 0,
  });

  @override
  AccountViewState createState() => AccountViewState();
}

class AccountViewState extends State<AccountView> {
  final GlobalKey<ScaffoldState> scaffold_key = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> user_info_view_form_key = GlobalKey<FormState>();
  final GlobalKey<FormState> email_form_key = GlobalKey<FormState>();
  final GlobalKey<FormState> password_form_key = GlobalKey<FormState>();
  final GlobalKey<FormState> name_and_info_form_key = GlobalKey<FormState>();

  bool editing_email = false;
  bool editing_password = false;
  bool editing_name_and_info = false;

  String firstname = "";
  String lastname = "";
  String email = "";
  String birthday = "";
  int gender_index = 0;
  String country = "";
  DateTime date = get_over_18_date();

  bool password_visible = false;

  bool accept_terms = false;
  String birthday_label = "";

  bool password_verification_enabled = true;

  TextEditingController firstname_input_controller = TextEditingController();
  TextEditingController last_name_input_controller = TextEditingController();
  TextEditingController email_input_controller = TextEditingController();
  TextEditingController confirm_email_input_controller = TextEditingController();
  TextEditingController password_input_controller = TextEditingController();
  TextEditingController confirm_password_input_controller = TextEditingController();

  String gender_value = "";
  String? country_value = "";

  static DateTime first_date = DateTime(DateTime.now().year - 150, DateTime.now().month, DateTime.now().day);
  DateTime selected_date = get_over_18_date();

  late SharedPreferences prefs;

  late TranslationStream translation_stream;
  late TranslationStream translation_stream_gender;
  List<TranslationStream> translation_stream_list = [];

  int source_language_index = 0;

  double logo_image_width = 0;

  @override
  void initState() {
    source_language_index = widget.source_language_index;
    super.initState();
    init_state();
  }

  @override
  void dispose() {
    dispose_controllers();
    super.dispose();
  }

  bool linking_email = false;

  @override
  Widget build(BuildContext context) {
    bool email_linked = false;
    bool phone_linked = false;
    List<UserInfo> user_providers = [];

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      user_providers = user.providerData;
      email_linked = check_email_provider(user_providers: user_providers);
      phone_linked = check_phone_provider(user_providers: user_providers);
    }

    return AuthContainer(
      translation_stream_list: translation_stream_list,
      user_info_form_type: widget.auth_form_type,
      custom_background: widget.custom_background,
      has_language_picker: widget.has_language_picker,
      topbar_color: widget.topbar_color,
      text_color: widget.text_color,
      has_back_button: widget.has_back_button,
      update_source_language: update_source_language,
      child: Form(
        key: user_info_view_form_key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: sized_box_space,
            ),
            get_auth_view_logo(
              context: context,
              logo_path: widget.logo_path,
              logo_image_width: logo_image_width,
              image_border_radius: widget.image_border_radius,
            ),
            SizedBox(
              height: sized_box_space,
            ),
            user_id_button(),
            unlink_phone_button(phone_linked, user_providers),
            unlink_email_button(email_linked, user_providers),
            email_form_section(email_linked),
            password_form_section(email_linked),
            link_phone_button(phone_linked),
            link_email_button(email_linked),
            user_info_form_section(),
            second_button(),
            SizedBox(
              height: sized_box_space,
            ),
            main_button(),
            SizedBox(
              height: sized_box_space,
            ),
          ].where((widget) => widget != null).cast<Widget>().toList(),
        ),
      ),
    );
  }
}
