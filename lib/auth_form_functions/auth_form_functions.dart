import 'package:firebase_auth/firebase_auth.dart';

// Functions executed in Auth Screens.

class AuthFormFunctions {
  ConfirmationResult? confirmation_result;
  String? verification_id = '';

  AuthFormFunctions({
    this.confirmation_result,
    this.verification_id,
  });
}
