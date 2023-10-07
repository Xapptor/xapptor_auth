// ignore_for_file: invalid_use_of_protected_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/account_view/validate_picker_value.dart';
import 'package:xapptor_logic/timestamp_to_date.dart';

extension StateExtension on AccountViewState {
  fill_fields() async {
    firstname_input_controller.text = firstname;
    last_name_input_controller.text = lastname;
    email_input_controller.text = email;
    confirm_email_input_controller.text = email;
    password_input_controller.text = "Aa00000000";
    confirm_password_input_controller.text = "Aa00000000";
    birthday_label = birthday;
    gender_value = widget.gender_values.get(source_language_index)[gender_index];
    country_value = widget.country_values != null ? validate_picker_value(country, widget.country_values!) : "";
    selected_date = date;

    password_visible = false;

    if (linking_email) {
      linking_email = false;
    }
    setState(() {});
  }

  fetch_fields() async {
    if (FirebaseAuth.instance.currentUser != null) {
      User auth_user = FirebaseAuth.instance.currentUser!;
      DocumentSnapshot user = await FirebaseFirestore.instance.collection("users").doc(auth_user.uid).get();

      Map user_data = user.data() as Map;

      firstname = user_data["firstname"] ?? "";
      lastname = user_data["lastname"] ?? "";
      email = auth_user.email ?? "";

      if (user_data["birthday"] != null) {
        birthday = timestamp_to_date_string(user_data["birthday"]);
        date = DateTime.parse(user_data["birthday"].toDate().toString());
      }

      gender_index = user_data["gender"] ?? 0;
      country = user_data["country"] ?? "";

      if (firstname.isEmpty || lastname.isEmpty) {
        editing_name_and_info = true;
      }
      fill_fields();
    }
  }
}
