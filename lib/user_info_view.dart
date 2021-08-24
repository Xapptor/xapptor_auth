import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:xapptor_ui/widgets/custom_card.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:xapptor_ui/screens/user_info_view_container.dart';
import 'package:xapptor_ui/webview/webview.dart';
import 'check_login.dart';
import 'package:xapptor_logic/check_metadata_app.dart';
import 'package:xapptor_logic/timestamp_to_date.dart';
import 'form_field_validators.dart';
import 'user_info_form_functions.dart';
import 'package:xapptor_translation/translate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'user_info_form_type.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoView extends StatefulWidget {
  const UserInfoView({
    required this.uid,
    required this.text_list,
    required this.first_button_action,
    required this.second_button_action,
    required this.third_button_action,
    required this.gender_values,
    required this.country_values,
    required this.text_color,
    required this.first_button_color,
    required this.second_button_color,
    required this.third_button_color,
    required this.logo_image_path,
    required this.topbar_color,
    required this.has_language_picker,
    required this.custom_background,
    required this.user_info_form_type,
    required this.outline_border,
    required this.secret_question_values,
    required this.secret_answer_values,
    required this.has_back_button,
    required this.text_field_background_color,
    this.edit_icon_use_text_field_background_color,
  });

  final String uid;
  final List<String> text_list;
  final Function? first_button_action;
  final Function? second_button_action;
  final Function? third_button_action;
  final List<String> gender_values;
  final List<String>? country_values;
  final Color text_color;
  final LinearGradient first_button_color;
  final Color second_button_color;
  final Color third_button_color;
  final String logo_image_path;
  final Color topbar_color;
  final bool has_language_picker;
  final Widget? custom_background;
  final UserInfoFormType user_info_form_type;
  final bool outline_border;
  final List<String> secret_question_values;
  final List<List<String>> secret_answer_values;
  final bool has_back_button;
  final Color? text_field_background_color;
  final bool? edit_icon_use_text_field_background_color;

  @override
  _UserInfoViewState createState() => _UserInfoViewState();
}

class _UserInfoViewState extends State<UserInfoView> {
  final GlobalKey<ScaffoldState> scaffold_key = new GlobalKey<ScaffoldState>();

  bool editing_email = false;
  bool editing_password = false;
  bool editing_name_and_info = false;

  final GlobalKey<FormState> email_form_key = GlobalKey<FormState>();
  final GlobalKey<FormState> password_form_key = GlobalKey<FormState>();
  final GlobalKey<FormState> name_and_info_form_key = GlobalKey<FormState>();

  String firstname = "";
  String lastname = "";
  String email = "";
  String birthday = "";
  String gender = "";
  String country = "";
  DateTime date = DateTime.now();

  bool _password_visible = false;
  bool remember_me = false;

  late String user_id;
  bool filled_fields = false;
  String current_language = "en";
  bool accept_terms = false;
  String birthday_label = "";

  final GlobalKey<FormState> user_info_view_form_key = GlobalKey<FormState>();

  TextEditingController firstname_input_controller = TextEditingController();
  TextEditingController last_name_input_controller = TextEditingController();
  TextEditingController email_input_controller = TextEditingController();
  TextEditingController confirm_email_input_controller =
      TextEditingController();
  TextEditingController password_input_controller = TextEditingController();
  TextEditingController confirm_password_input_controller =
      TextEditingController();

  String gender_value = "";
  String? country_value = "";

  String secret_question_value = "";
  int secret_question_current_index = 0;
  String secret_answer_value = "";

  static DateTime over_18 = DateTime(
      DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
  static DateTime first_date = DateTime(
      DateTime.now().year - 150, DateTime.now().month, DateTime.now().day);
  DateTime selected_date = over_18;

  Future<Null> _select_date(BuildContext context) async {
    final DateTime? picked = (await showDatePicker(
      context: context,
      initialDate: selected_date,
      firstDate: first_date,
      lastDate: over_18,
    ));
    if (picked != null)
      setState(() {
        selected_date = picked;

        DateFormat date_formatter = DateFormat.yMMMMd('en_US');
        String date_now_formatted = date_formatter.format(selected_date);
        birthday_label = date_now_formatted;
      });
  }

  late SharedPreferences prefs;
  TranslationStream translation_stream = TranslationStream();

  init_prefs(Function is_login) async {
    prefs = await SharedPreferences.getInstance();

    if (is_login(widget.user_info_form_type) &&
        prefs.getString("email") != null) {
      email_input_controller.text = prefs.getString("email")!;
      remember_me = true;
      setState(() {});
    }
  }

  update_text_list(int index, String new_text) {
    widget.text_list[index] = new_text;
    setState(() {});
  }

  @override
  void dispose() {
    firstname_input_controller.dispose();
    last_name_input_controller.dispose();
    email_input_controller.dispose();
    confirm_email_input_controller.dispose();
    password_input_controller.dispose();
    confirm_password_input_controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    check_metadata_app();
    if (widget.user_info_form_type == UserInfoFormType.login) check_login();

    init_prefs(is_login);
    translation_stream.init(widget.text_list, update_text_list);
    translation_stream.translate();

    if (is_register(widget.user_info_form_type) ||
        is_edit_account(widget.user_info_form_type)) {
      setState(() {
        gender_value = widget.gender_values[0];
        country_value = widget.country_values?[0];
      });
    }

    if (widget.secret_question_values.isNotEmpty &&
        widget.secret_answer_values.isNotEmpty) {
      secret_question_value = widget.secret_question_values[0];
      secret_answer_value = widget.secret_answer_values[0][0];
    }
  }

  language_picker_callback(String new_current_language) async {
    current_language = new_current_language;
    translation_stream.translate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    user_id = widget.uid;
    if (is_edit_account(widget.user_info_form_type)) fetch_fields();
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double screen_width = MediaQuery.of(context).size.width;

    return UserInfoViewContainer(
      user_info_form_type: widget.user_info_form_type,
      custom_background: widget.custom_background,
      has_language_picker: widget.has_language_picker,
      topbar_color: widget.topbar_color,
      text_color: widget.text_color,
      current_language: current_language,
      language_picker_callback: language_picker_callback,
      has_back_button: widget.has_back_button,
      child: FractionallySizedBox(
        widthFactor: portrait ? 0.75 : 0.25,
        child: Form(
          key: user_info_view_form_key,
          child: Row(
            children: [
              is_edit_account(widget.user_info_form_type)
                  ? Spacer(flex: 1)
                  : Container(),
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: sized_box_space,
                    ),
                    Container(
                      child: widget.logo_image_path.contains("http")
                          ? Container(
                              height: logo_height(context),
                              width: logo_width(context),
                              child: Webview(
                                id: "20",
                                src: widget.logo_image_path,
                                function: () {},
                              ),
                            )
                          : Container(
                              height: logo_height(context),
                              width: logo_width(context),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: AssetImage(
                                    widget.logo_image_path,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    is_forgot_password(widget.user_info_form_type)
                        ? Column(
                            children: [
                              SizedBox(
                                height: sized_box_space,
                              ),
                              Text(
                                widget.text_list[0],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: widget.text_color,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: sized_box_space,
                    ),
                    Container(
                      padding: EdgeInsets.all(
                        outline_padding,
                      ),
                      decoration: BoxDecoration(
                        color: widget.text_field_background_color ??
                            Colors.transparent,
                        border: Border.all(
                          width: outline_width,
                          color: widget.outline_border
                              ? widget.text_color
                              : widget.text_field_background_color!,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(outline_border_radius),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            style: TextStyle(color: widget.text_color),
                            enabled: is_edit_account(widget.user_info_form_type)
                                ? editing_email
                                : true,
                            decoration: InputDecoration(
                              labelText: widget.text_list[0],
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
                              type: FormFieldValidatorsType.email,
                            ).validate(),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(
                            height: sized_box_space,
                          ),
                          is_register(widget.user_info_form_type) ||
                                  is_edit_account(
                                    widget.user_info_form_type,
                                  )
                              ? TextFormField(
                                  style: TextStyle(color: widget.text_color),
                                  enabled: is_edit_account(
                                    widget.user_info_form_type,
                                  )
                                      ? editing_email
                                      : true,
                                  decoration: InputDecoration(
                                    labelText: widget.text_list[1],
                                    labelStyle: TextStyle(
                                      color: widget.text_color,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: widget.text_color,
                                      ),
                                    ),
                                  ),
                                  controller: confirm_email_input_controller,
                                  validator: (value) => FormFieldValidators(
                                    value: value!,
                                    type: FormFieldValidatorsType.email,
                                  ).validate(),
                                  keyboardType: TextInputType.emailAddress,
                                )
                              : Container(),
                          widget.secret_question_values.isNotEmpty &&
                                  widget.secret_answer_values.isNotEmpty
                              ? Container(
                                  child: Column(
                                    children: [
                                      DropdownButton<String>(
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: widget.text_color,
                                        ),
                                        isExpanded: true,
                                        value: secret_question_value,
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(
                                          color: widget.text_color,
                                        ),
                                        underline: Container(
                                          height: 1,
                                          color: widget.text_color,
                                        ),
                                        onChanged: (new_value) {
                                          setState(() {
                                            secret_question_value = new_value!;
                                            secret_question_current_index =
                                                widget.secret_question_values
                                                    .indexOf(
                                                        secret_question_value);
                                            secret_answer_value = widget
                                                    .secret_answer_values[
                                                secret_question_current_index][0];
                                          });
                                        },
                                        items: widget.secret_question_values
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(
                                        height: sized_box_space,
                                      ),
                                      DropdownButton<String>(
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: widget.text_color,
                                        ),
                                        isExpanded: true,
                                        value: secret_answer_value,
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(
                                          color: widget.text_color,
                                        ),
                                        underline: Container(
                                          height: 1,
                                          color: widget.text_color,
                                        ),
                                        onChanged: (new_value) {
                                          setState(() {
                                            secret_answer_value = new_value!;
                                          });
                                        },
                                        items: widget.secret_answer_values[
                                                secret_question_current_index]
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    !is_forgot_password(widget.user_info_form_type)
                        ? Column(
                            children: [
                              SizedBox(
                                height: sized_box_space,
                              ),
                              Container(
                                padding: EdgeInsets.all(
                                  outline_padding,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.text_field_background_color ??
                                      Colors.transparent,
                                  border: Border.all(
                                    width: outline_width,
                                    color: widget.outline_border
                                        ? widget.text_color
                                        : widget.text_field_background_color!,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(outline_border_radius),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      style:
                                          TextStyle(color: widget.text_color),
                                      enabled: is_edit_account(
                                              widget.user_info_form_type)
                                          ? editing_password
                                          : true,
                                      decoration: InputDecoration(
                                        labelText: widget.text_list[
                                            is_login(widget.user_info_form_type)
                                                ? 1
                                                : 2],
                                        labelStyle: TextStyle(
                                          color: widget.text_color,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: widget.text_color,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
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
                                        ),
                                      ),
                                      controller: password_input_controller,
                                      validator: (value) => FormFieldValidators(
                                        value: value!,
                                        type: FormFieldValidatorsType.password,
                                      ).validate(),
                                      obscureText: !_password_visible,
                                    ),
                                    SizedBox(
                                      height: sized_box_space,
                                    ),
                                    !is_login(widget.user_info_form_type)
                                        ? TextFormField(
                                            style: TextStyle(
                                              color: widget.text_color,
                                            ),
                                            enabled: is_edit_account(
                                                    widget.user_info_form_type)
                                                ? editing_password
                                                : true,
                                            decoration: InputDecoration(
                                              labelText: widget.text_list[3],
                                              labelStyle: TextStyle(
                                                color: widget.text_color,
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: widget.text_color,
                                                ),
                                              ),
                                            ),
                                            controller:
                                                confirm_password_input_controller,
                                            validator: (value) =>
                                                FormFieldValidators(
                                              value: value!,
                                              type: FormFieldValidatorsType
                                                  .password,
                                            ).validate(),
                                            obscureText: true,
                                          )
                                        : TextButton(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                  ),
                                                ),
                                              ),
                                            ),
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
                                                        : Icons
                                                            .check_box_outline_blank,
                                                    color: widget.text_color,
                                                  ),
                                                  margin: EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                ),
                                                Text(
                                                  widget.text_list[2],
                                                  style: TextStyle(
                                                    color: widget.text_color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              )
                            ],
                          )
                        : Container(),
                    is_register(widget.user_info_form_type) ||
                            is_edit_account(widget.user_info_form_type)
                        ? Column(
                            children: [
                              SizedBox(
                                height: sized_box_space,
                              ),
                              Container(
                                padding: EdgeInsets.all(
                                  outline_padding,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.text_field_background_color ??
                                      Colors.transparent,
                                  border: Border.all(
                                    width: outline_width,
                                    color: widget.outline_border
                                        ? widget.text_color
                                        : widget.text_field_background_color!,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(outline_border_radius),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      style:
                                          TextStyle(color: widget.text_color),
                                      enabled: is_edit_account(
                                              widget.user_info_form_type)
                                          ? editing_name_and_info
                                          : true,
                                      decoration: InputDecoration(
                                        labelText: widget.text_list[4],
                                        labelStyle: TextStyle(
                                          color: widget.text_color,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: widget.text_color,
                                          ),
                                        ),
                                      ),
                                      controller: firstname_input_controller,
                                      validator: (value) => FormFieldValidators(
                                        value: value!,
                                        type: FormFieldValidatorsType.name,
                                      ).validate(),
                                    ),
                                    SizedBox(
                                      height: sized_box_space,
                                    ),
                                    TextFormField(
                                      style:
                                          TextStyle(color: widget.text_color),
                                      enabled: is_edit_account(
                                              widget.user_info_form_type)
                                          ? editing_name_and_info
                                          : true,
                                      decoration: InputDecoration(
                                        labelText: widget.text_list[5],
                                        labelStyle: TextStyle(
                                          color: widget.text_color,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: widget.text_color,
                                          ),
                                        ),
                                      ),
                                      controller: last_name_input_controller,
                                      validator: (value) => FormFieldValidators(
                                        value: value!,
                                        type: FormFieldValidatorsType.name,
                                      ).validate(),
                                    ),
                                    SizedBox(
                                      height: sized_box_space,
                                    ),
                                    Container(
                                      width: screen_width,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          elevation:
                                              MaterialStateProperty.all<double>(
                                            0,
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            Colors.transparent,
                                          ),
                                          overlayColor:
                                              MaterialStateProperty.all<Color>(
                                            Colors.grey.withOpacity(0.2),
                                          ),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                              ),
                                              side: BorderSide(
                                                color: widget.text_color,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (is_edit_account(
                                              widget.user_info_form_type)) {
                                            if (editing_name_and_info) {
                                              _select_date(context);
                                            }
                                          } else {
                                            _select_date(context);
                                          }
                                        },
                                        child: Text(
                                          birthday_label != ""
                                              ? birthday_label
                                              : widget.text_list[6],
                                          style: TextStyle(
                                            color: widget.text_color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: sized_box_space,
                                    ),
                                    DropdownButton<String>(
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: widget.text_color,
                                      ),
                                      isExpanded: true,
                                      value: gender_value == ""
                                          ? widget.gender_values[0]
                                          : gender_value,
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                        color: widget.text_color,
                                      ),
                                      underline: Container(
                                        height: 1,
                                        color: widget.text_color,
                                      ),
                                      onChanged: (new_value) {
                                        if (is_edit_account(
                                            widget.user_info_form_type)) {
                                          if (editing_name_and_info) {
                                            setState(() {
                                              gender_value = new_value!;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            gender_value = new_value!;
                                          });
                                        }
                                      },
                                      items: widget.gender_values
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(
                                      height: sized_box_space,
                                    ),
                                    widget.country_values != null
                                        ? DropdownButton<String>(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: widget.text_color,
                                            ),
                                            isExpanded: true,
                                            value: country_value == ""
                                                ? widget.country_values![0]
                                                : country_value,
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                              color: widget.text_color,
                                            ),
                                            underline: Container(
                                              height: 1,
                                              color: widget.text_color,
                                            ),
                                            onChanged: (new_value) {
                                              if (is_edit_account(
                                                  widget.user_info_form_type)) {
                                                if (editing_name_and_info) {
                                                  setState(() {
                                                    country_value = new_value!;
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  country_value = new_value!;
                                                });
                                              }
                                            },
                                            items: widget.country_values!
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          )
                                        : Container(),
                                    is_register(widget.user_info_form_type)
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                height: sized_box_space,
                                              ),
                                              Container(
                                                child: TextButton(
                                                  style: ButtonStyle(
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    accept_terms =
                                                        !accept_terms;
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          child: Icon(
                                                            accept_terms
                                                                ? Icons
                                                                    .check_box_outlined
                                                                : Icons
                                                                    .check_box_outline_blank,
                                                            color: widget
                                                                .text_color,
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(flex: 1),
                                                      Expanded(
                                                        flex: 12,
                                                        child: Text(
                                                          widget.text_list[7],
                                                          textAlign:
                                                              TextAlign.left,
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          style: TextStyle(
                                                            color: widget
                                                                .text_color,
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(flex: 1),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: sized_box_space,
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    is_login(widget.user_info_form_type)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: sized_box_space,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            screen_width,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (widget.second_button_action != null) {
                                        widget.second_button_action!();
                                      }
                                    },
                                    child: Text(
                                      widget.text_list[4],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: widget.second_button_color,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            screen_width,
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
                                      widget.text_list[5],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: widget.third_button_color,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: sized_box_space,
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
                        splash_color:
                            widget.second_button_color.withOpacity(0.2),
                        child: Center(
                          child: Text(
                            widget.text_list[
                                is_edit_account(widget.user_info_form_type)
                                    ? 7
                                    : is_login(widget.user_info_form_type)
                                        ? 3
                                        : is_forgot_password(
                                                widget.user_info_form_type)
                                            ? 2
                                            : 8],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (widget.first_button_color.colors.first ==
                                          Colors.transparent &&
                                      widget.first_button_color.colors.last ==
                                          Colors.transparent)
                                  ? widget.second_button_color
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: sized_box_space * 2,
                    ),
                  ],
                ),
              ),
              is_edit_account(widget.user_info_form_type)
                  ? Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Spacer(flex: 6),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                editing_email
                                    ? Icons.delete_outlined
                                    : Icons.edit,
                                color: get_edit_icon_color(),
                              ),
                              onPressed: () {
                                editing_email = !editing_email;
                                if (!editing_email) {
                                  filled_fields = false;
                                  fill_fields();
                                }
                                setState(() {});
                              },
                            ),
                          ),
                          Spacer(flex: 3),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                editing_password
                                    ? Icons.delete_outlined
                                    : Icons.edit,
                                color: get_edit_icon_color(),
                              ),
                              onPressed: () {
                                editing_password = !editing_password;
                                if (!editing_password) {
                                  filled_fields = false;
                                  fill_fields();
                                } else {
                                  password_input_controller.text = "";
                                  confirm_password_input_controller.text = "";
                                }
                                setState(() {});
                              },
                            ),
                          ),
                          Spacer(flex: 3),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                editing_name_and_info
                                    ? Icons.delete_outlined
                                    : Icons.edit,
                                color: get_edit_icon_color(),
                              ),
                              onPressed: () {
                                editing_name_and_info = !editing_name_and_info;
                                if (!editing_name_and_info) {
                                  filled_fields = false;
                                  fill_fields();
                                }
                                setState(() {});
                              },
                            ),
                          ),
                          Spacer(flex: 9),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  on_pressed_first_button() {
    if (widget.first_button_action == null) {
      if (is_edit_account(widget.user_info_form_type)) {
        if (editing_email || editing_password || editing_name_and_info) {
          show_alert_dialog(context);
        }
      } else if (is_register(widget.user_info_form_type)) {
        List<TextEditingController> inputControllers = [
          firstname_input_controller,
          last_name_input_controller,
          email_input_controller,
          confirm_email_input_controller,
          password_input_controller,
          confirm_password_input_controller,
        ];

        UserInfoFormFunctions().register(
          context: context,
          accept_terms: accept_terms,
          register_form_key: user_info_view_form_key,
          input_controllers: inputControllers,
          selected_date: selected_date,
          gender_value: gender_value,
          country_value: country_value ?? "",
          birthday_label: birthday_label,
        );
      } else if (is_login(widget.user_info_form_type)) {
        List<TextEditingController> inputControllers = [
          email_input_controller,
          password_input_controller,
        ];

        UserInfoFormFunctions().login(
          context: context,
          remember_me: remember_me,
          login_form_key: user_info_view_form_key,
          input_controllers: inputControllers,
          prefs: prefs,
          persistence: Persistence.LOCAL,
        );
      } else if (is_forgot_password(widget.user_info_form_type)) {
        UserInfoFormFunctions().forgot_password(
          context: context,
          forgot_password_form_key: user_info_view_form_key,
          email_input_controller: email_input_controller,
        );
      }
    } else {
      widget.first_button_action!();
    }
  }

  Color get_edit_icon_color() {
    return widget.edit_icon_use_text_field_background_color != null
        ? widget.edit_icon_use_text_field_background_color!
            ? widget.text_field_background_color != null
                ? widget.text_field_background_color!
                : widget.text_color
            : widget.text_color
        : widget.text_color;
  }

  show_alert_dialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Do you want to save the changes?"),
          actions: <Widget>[
            TextButton(
              child: Text("Discard"),
              onPressed: () {
                Navigator.of(context).pop();
                editing_email = false;
                editing_password = false;
                editing_name_and_info = false;
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Accept"),
              onPressed: () {
                if (editing_email ||
                    editing_password ||
                    editing_name_and_info) {
                  show_password_verification_alert_dialog(
                    context: context,
                    email: email,
                    text_color: widget.text_color,
                    function: () async {
                      if (editing_name_and_info) {
                        List<TextEditingController> inputControllers = [
                          firstname_input_controller,
                          last_name_input_controller,
                        ];

                        UserInfoFormFunctions().update_user_name_and_info(
                          context: context,
                          scaffold_key: scaffold_key,
                          name_and_info_form_key: user_info_view_form_key,
                          input_controllers: inputControllers,
                          selected_date: selected_date,
                          gender_value: gender_value,
                          country_value: country_value ?? "",
                          user_id: user_id,
                          editing_name_and_info: editing_name_and_info,
                          widget_parent: this,
                        );
                      }

                      if (editing_password) {
                        List<TextEditingController> inputControllers = [
                          password_input_controller,
                          confirm_password_input_controller,
                        ];

                        await UserInfoFormFunctions().update_user_password(
                          context: context,
                          scaffold_key: scaffold_key,
                          password_form_key: user_info_view_form_key,
                          input_controllers: inputControllers,
                          user_id: user_id,
                          email: email_input_controller.text,
                          editing_password: editing_password,
                          widget_parent: this,
                        );
                      }

                      if (editing_email) {
                        List<TextEditingController> inputControllers = [
                          email_input_controller,
                          confirm_email_input_controller,
                        ];

                        UserInfoFormFunctions().update_user_email(
                          context: context,
                          scaffold_key: scaffold_key,
                          email_form_key: user_info_view_form_key,
                          input_controllers: inputControllers,
                          user_id: user_id,
                          editing_email: editing_email,
                          widget_parent: this,
                        );
                      }
                    },
                  );
                }
              },
            )
          ],
        );
      },
    );
  }

  show_password_verification_alert_dialog({
    required BuildContext context,
    required String email,
    required Color text_color,
    required Function function,
  }) async {
    TextEditingController password_input_controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter current password"),
          content: TextFormField(
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(
                color: text_color,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: text_color,
                ),
              ),
            ),
            controller: password_input_controller,
            validator: (value) => FormFieldValidators(
              value: value!,
              type: FormFieldValidatorsType.password,
            ).validate(),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Accept"),
              onPressed: () async {
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                  email: email,
                  password: password_input_controller.text,
                )
                    .then((UserCredential userCredential) async {
                  function();
                }).catchError((onError) {
                  print(onError);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("The password is invalid"),
                    duration: Duration(milliseconds: 1500),
                  ));
                });
              },
            ),
          ],
        );
      },
    );
  }

  fetch_fields() async {
    if (!filled_fields) {
      filled_fields = true;
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection("users")
          .doc(user_id)
          .get();

      print(user.data());
      User auth_user = FirebaseAuth.instance.currentUser!;

      firstname = user.get("firstname");
      lastname = user.get("lastname");
      email = auth_user.email!;
      birthday = timestamp_to_date(user.get("birthday"));
      gender = user.get("gender");
      country = user.get("country");
      date = DateTime.parse(user.get("birthday").toDate().toString());

      fill_fields();
    }
  }

  fill_fields() async {
    firstname_input_controller.text = firstname;
    last_name_input_controller.text = lastname;
    email_input_controller.text = email;
    confirm_email_input_controller.text = email;
    password_input_controller.text = "Aa00000000";
    confirm_password_input_controller.text = "Aa00000000";
    birthday_label = birthday;
    gender_value = validate_picker_value(gender, widget.gender_values);
    country_value = widget.country_values != null
        ? validate_picker_value(country, widget.country_values!)
        : "";
    selected_date = date;
    setState(() {});
  }

  String validate_picker_value(String value, List<String> list) {
    bool match = false;
    for (var list_item in list) {
      if (list_item == value) match = true;
    }
    return match ? value : list.first;
  }
}
