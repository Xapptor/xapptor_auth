import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_auth/auth_form_functions/auth_form_functions.dart';
import 'package:xapptor_auth/auth_form_functions/show_user_info_saved_message.dart';

extension UpdateUserNameAndInfo on AuthFormFunctions {
  update_user_name_and_info({
    required BuildContext context,
    required GlobalKey<ScaffoldState> scaffold_key,
    required GlobalKey<FormState> name_and_info_form_key,
    required List<TextEditingController> input_controllers,
    required DateTime selected_date,
    required int gender_value,
    required String country_value,
    required String user_id,
    required bool password_verification_enabled,
  }) {
    TextEditingController firstname_input_controller = input_controllers[0];
    TextEditingController lastname_input_controller = input_controllers[1];

    Timestamp birthday_timestamp = Timestamp.fromDate(selected_date);

    if (name_and_info_form_key.currentState!.validate()) {
      FirebaseFirestore.instance.collection("users").doc(user_id).update({
        "firstname": firstname_input_controller.text,
        "lastname": lastname_input_controller.text,
        "birthday": birthday_timestamp,
        "gender": gender_value,
        "country": country_value,
      }).then((result) {
        show_user_info_saved_message(context);
      }).catchError((err) {
        print(err);
      });
    }
  }
}
