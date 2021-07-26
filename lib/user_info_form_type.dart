enum UserInfoFormType {
  login,
  register,
  edit_account,
  forgot_password,
}

is_login(UserInfoFormType user_info_form_type) {
  if (user_info_form_type == UserInfoFormType.login) {
    return true;
  } else {
    return false;
  }
}

is_register(UserInfoFormType user_info_form_type) {
  if (user_info_form_type == UserInfoFormType.register) {
    return true;
  } else {
    return false;
  }
}

is_edit_account(UserInfoFormType user_info_form_type) {
  if (user_info_form_type == UserInfoFormType.edit_account) {
    return true;
  } else {
    return false;
  }
}

is_forgot_password(UserInfoFormType user_info_form_type) {
  if (user_info_form_type == UserInfoFormType.forgot_password) {
    return true;
  } else {
    return false;
  }
}
