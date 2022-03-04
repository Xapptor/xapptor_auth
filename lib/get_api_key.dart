import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_auth/initial_values.dart';

// API key search in metadata collection (Firebase Firestore).
// *CAUTION* You have to follow the security rules to ensure privacy in your metadata collection in Firebase Firestore.

Future<String> get_api_key({
  required String name,
  required String organization,
}) async {
  DocumentSnapshot organization_metadata = await FirebaseFirestore.instance
      .collection("metadata")
      .doc(organization)
      .get();
  Map<String, dynamic> organization_data =
      organization_metadata.data() as Map<String, dynamic>;
  String api_key = "";

  if (UniversalPlatform.isAndroid) {
    api_key = organization_data["keys"][name]["android"];
  } else if (UniversalPlatform.isIOS) {
    api_key = organization_data["keys"][name]["ios"];
  } else if (UniversalPlatform.isWeb) {
    api_key = organization_data["keys"][name]["web"];
  }

  if (d_m_f_au != null) {
    api_key = d_m_f_au!(
      m: api_key,
      k: e_k_au,
    );
  }

  return api_key;
}
