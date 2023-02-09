// User Info Form Types.

enum AuthFormType {
  login,
  register,
  edit_account,
}

// Check if User Info Form is Login.
bool is_login(AuthFormType user_info_form_type) =>
    user_info_form_type == AuthFormType.login;

// Check if User Info Form is Register.
bool is_register(AuthFormType user_info_form_type) =>
    user_info_form_type == AuthFormType.register;

// Check if User Info Form is Edit Account.
bool is_edit_account(AuthFormType user_info_form_type) =>
    user_info_form_type == AuthFormType.edit_account;
