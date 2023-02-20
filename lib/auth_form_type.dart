// User Info Form Types.

enum AuthFormType {
  login,
  quick_login,
  restore_password,
  register,
  edit_account,
}

bool is_login(AuthFormType auth_form_type) =>
    auth_form_type == AuthFormType.login;

bool is_quick_login(AuthFormType auth_form_type) =>
    auth_form_type == AuthFormType.quick_login;

bool is_register(AuthFormType auth_form_type) =>
    auth_form_type == AuthFormType.register;

bool is_edit_account(AuthFormType auth_form_type) =>
    auth_form_type == AuthFormType.edit_account;
