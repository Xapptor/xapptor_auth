// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xapptor_auth/account_view/account_view.dart';
import 'package:xapptor_auth/get_over_18_date.dart';

extension SelectDate on AccountViewState {
  Future select_date() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selected_date,
      firstDate: AccountViewState.first_date,
      lastDate: get_over_18_date(),
    );
    if (picked != null) {
      setState(() {
        selected_date = picked;

        DateFormat date_formatter = DateFormat.yMMMMd('en_US');
        String date_now_formatted = date_formatter.format(selected_date);
        birthday_label = date_now_formatted;
      });
    }
  }
}
