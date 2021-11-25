// User Info Form Types.

enum UserInfoFormType {
  login,
  register,
  edit_account,
  forgot_password,
}

// Check if User Info Form is Login.
bool is_login(UserInfoFormType user_info_form_type) =>
    user_info_form_type == UserInfoFormType.login;

// Check if User Info Form is Register.
bool is_register(UserInfoFormType user_info_form_type) =>
    user_info_form_type == UserInfoFormType.register;

// Check if User Info Form is Edit Account.
bool is_edit_account(UserInfoFormType user_info_form_type) =>
    user_info_form_type == UserInfoFormType.edit_account;

// Check if User Info Form is Forgot Password.
bool is_forgot_password(UserInfoFormType user_info_form_type) =>
    user_info_form_type == UserInfoFormType.forgot_password;
