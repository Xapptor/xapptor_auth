/// Phone code detection module for xapptor_auth.
///
/// This module provides automatic phone country code detection based on the user's IP address.
/// It uses the same geolocation APIs as xapptor_translation for consistency.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:xapptor_auth/phone_code_detection/phone_code_detection.dart';
///
/// // Get the detected country with dial code
/// final country = await detect_phone_country_code();
/// print('Dial code: ${country.dial_code}'); // e.g., "+52" for Mexico
/// ```
///
/// ## Features
///
/// - Automatic country detection via IP geolocation
/// - Multiple fallback API providers for reliability
/// - 24-hour caching to minimize API calls
/// - Graceful fallback on detection failure
///
library phone_code_detection;

export 'phone_code_detector.dart';
