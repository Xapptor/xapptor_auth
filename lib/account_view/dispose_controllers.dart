import 'package:xapptor_auth/account_view/account_view.dart';

extension StateExtension on AccountViewState {
  dispose_controllers() {
    firstname_input_controller.dispose();
    last_name_input_controller.dispose();
    email_input_controller.dispose();
    confirm_email_input_controller.dispose();
    password_input_controller.dispose();
    confirm_password_input_controller.dispose();
  }
}
