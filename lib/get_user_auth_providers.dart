import 'package:firebase_auth/firebase_auth.dart';

List<String> get_user_auth_providers() {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> providers = [];
  if (user != null) {
    providers = user.providerData.map((e) => e.providerId).toList();
  }
  return providers;
}
