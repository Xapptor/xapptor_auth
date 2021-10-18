// User Info Form Types.

enum UserInfoFormType {
  login,
  register,
  edit_account,
  forgot_password,
}

// Check if User Info Form is Login.

is_login(UserInfoFormType user_info_form_type) {
  if (user_info_form_type == UserInfoFormType.login) {
    return true;
  } else {
    return false;
  }
}

// Check if User Info Form is Register.

is_register(UserInfoFormType user_info_form_type) {
  if (user_info_form_type == UserInfoFormType.register) {
    return true;
  } else {
    return false;
  }
}

// Check if User Info Form is Edit Account.

is_edit_account(UserInfoFormType user_info_form_type) {
  if (user_info_form_type == UserInfoFormType.edit_account) {
    return true;
  } else {
    return false;
  }
}

// Check if User Info Form is Forgot Password.

is_forgot_password(UserInfoFormType user_info_form_type) {
  if (user_info_form_type == UserInfoFormType.forgot_password) {
    return true;
  } else {
    return false;
  }
}
