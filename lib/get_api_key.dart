import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_platform/universal_platform.dart';

// GCP API key search in metadata collection of Firebase Firestore.

Future<String> get_api_key({required String name}) async {
  DocumentSnapshot gcp =
      await FirebaseFirestore.instance.collection("metadata").doc("gcp").get();
  Map<String, dynamic> gcp_data = gcp.data() as Map<String, dynamic>;
  String api_key = "";

  if (UniversalPlatform.isAndroid) {
    api_key = gcp_data["keys"][name]["android"];
  } else if (UniversalPlatform.isIOS) {
    api_key = gcp_data["keys"][name]["ios"];
  } else if (UniversalPlatform.isWeb) {
    api_key = gcp_data["keys"][name]["web"];
  }

  return api_key;
}
