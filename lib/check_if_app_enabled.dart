import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:xapptor_db/xapptor_db.dart';

// Check if the app is enabled in the current platform.
// Search param in metadata collection of Firebase Firestore.

check_if_app_enabled() async {
  bool app_enabled = false;
  DocumentSnapshot metadata_app = await XapptorDB.instance.collection('metadata').doc('app').get();

  String platform = "";
  if (UniversalPlatform.isAndroid) {
    platform = "android";
  } else if (UniversalPlatform.isIOS) {
    platform = "ios";
  } else if (UniversalPlatform.isWeb) {
    platform = "web";
  }
  app_enabled = metadata_app["enabled"][platform];

  debugPrint("app_enabled: $app_enabled");
  if (!app_enabled) exit(0);
}
