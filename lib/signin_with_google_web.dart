import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:xapptor_db/xapptor_db.dart';
import 'package:xapptor_router/V2/app_screens_v2.dart';

StreamSubscription<GoogleSignInUserData?>? _google_user_data_subscription;

/// Initializes the Google Sign-In listener for web platform.
///
/// This sets up a listener on `userDataEvents` from Google Identity Services.
/// When the user signs in via the `renderButton()`, this listener receives
/// the user data including the ID token (which contains user info as JWT claims).
///
/// Unlike the old `signIn()` method, this approach:
/// - Uses Google's official Sign-In button UI
/// - Gets user info from the ID token (no People API needed)
/// - Is the recommended approach for web as of 2024
void init_google_signin_web_listener() {
  if (!kIsWeb) return;

  final plugin = GoogleSignInPlatform.instance;
  if (plugin is! GoogleSignInPlugin) return;

  // Cancel any existing subscription
  _google_user_data_subscription?.cancel();

  // Listen for user data from Google Identity Services
  _google_user_data_subscription = plugin.userDataEvents?.listen(
    (GoogleSignInUserData? data) async {
      if (data == null) {
        debugPrint("Google Sign-In: No user data received");
        return;
      }

      debugPrint("Google Sign-In Web: User authenticated - ${data.email}");

      try {
        await _signin_with_google_web(data);
      } catch (e) {
        debugPrint("Google Sign-In Web Error: $e");
      }
    },
    onError: (error) {
      debugPrint("Google Sign-In Web Stream Error: $error");
    },
  );
}

/// Handles the Google Sign-In authentication for web.
///
/// Uses the ID token from Google Identity Services to:
/// 1. Create Firebase credentials
/// 2. Sign in to Firebase
/// 3. Save user data to Firestore
/// 4. Navigate to home screen
Future<void> _signin_with_google_web(GoogleSignInUserData data) async {
  // The ID token contains user info as JWT claims
  final String? id_token = data.idToken;

  if (id_token == null) {
    debugPrint("Google Sign-In Web: No ID token available");
    return;
  }

  // Create Firebase credential from the ID token
  final AuthCredential credential = GoogleAuthProvider.credential(
    idToken: id_token,
  );

  // Extract name parts from display name
  String firstname = "";
  String lastname = "";

  if (data.displayName != null) {
    List<String> names = [];

    if ((data.displayName ?? "").contains(" ")) {
      names = data.displayName!.split(" ");
    } else {
      names = [data.displayName ?? ""];
    }

    if (names.length == 1) {
      firstname = names[0];
    } else {
      for (int i = 0; i < names.length; i++) {
        if (i < (names.length / 2).floor()) {
          firstname += "${names[i]} ";
        } else {
          lastname += "${names[i]} ";
        }
      }
    }

    firstname = firstname.trim();
    lastname = lastname.trim();
  }

  // Sign in to Firebase and save user data
  await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
    await XapptorDB.instance.collection("users").doc(value.user!.uid).set(
      {
        "email": data.email,
        "firstname": firstname,
        "lastname": lastname,
      },
      SetOptions(
        merge: true,
      ),
    ).then((value) {
      open_screen_v2("home");
    });
  });
}

/// Disposes the Google Sign-In web listener.
///
/// Call this when the login view is disposed to prevent memory leaks.
void dispose_google_signin_web_listener() {
  _google_user_data_subscription?.cancel();
  _google_user_data_subscription = null;
}
