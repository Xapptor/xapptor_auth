import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:flutter/foundation.dart';

// Check if the app is enabled in the current platform.
// Search param in metadata collection of Firebase Firestore.

check_if_app_enabled() async {
  bool app_enabled = false;
  DocumentSnapshot metadata_app = await FirebaseFirestore.instance.collection('metadata').doc('app').get();

  if (UniversalPlatform.isAndroid) {
    app_enabled = metadata_app["enabled"]["android"];
  } else if (UniversalPlatform.isIOS) {
    app_enabled = metadata_app["enabled"]["ios"];
  } else if (UniversalPlatform.isWeb) {
    app_enabled = metadata_app["enabled"]["web"];
  }
  debugPrint("app_enabled: $app_enabled");
  if (!app_enabled) exit(0);
}
