import 'package:firebase_auth/firebase_auth.dart';

bool check_provider({
  required List<UserInfo> user_providers,
  required String provider_id,
}) {
  return user_providers.map((e) => e.providerId).toList().contains(provider_id);
}

bool check_email_provider({
  required List<UserInfo> user_providers,
}) {
  return check_provider(
    user_providers: user_providers,
    provider_id: "password",
  );
}

bool check_phone_provider({
  required List<UserInfo> user_providers,
}) {
  return check_provider(
    user_providers: user_providers,
    provider_id: "phone",
  );
}
