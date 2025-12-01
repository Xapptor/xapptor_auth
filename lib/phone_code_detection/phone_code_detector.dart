import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xapptor_translation/language_detection/ip_language_detector.dart';
import 'package:xapptor_ui/values/country/country.dart';

/// Result model for phone code detection.
@immutable
class PhoneCodeDetectionResult {
  final bool success;
  final Country? country;
  final String source;
  final String? error_message;

  const PhoneCodeDetectionResult({
    required this.success,
    this.country,
    required this.source,
    this.error_message,
  });

  factory PhoneCodeDetectionResult.success({
    required Country country,
    required String source,
  }) {
    return PhoneCodeDetectionResult(
      success: true,
      country: country,
      source: source,
    );
  }

  factory PhoneCodeDetectionResult.failure(String error_message) {
    return PhoneCodeDetectionResult(
      success: false,
      source: 'error',
      error_message: error_message,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'PhoneCodeDetectionResult(country: ${country?.name}, dial_code: ${country?.dial_code}, source: $source)';
    }
    return 'PhoneCodeDetectionResult(error: $error_message)';
  }
}

/// Detects the user's phone country code based on their IP address.
///
/// Uses the same IP geolocation APIs as language detection for consistency.
/// Results are cached for 24 hours to minimize API calls.
class PhoneCodeDetector {
  static const String _cache_key_country_code = 'phone_code_detected_country';
  static const String _cache_key_timestamp = 'phone_code_detection_timestamp';
  static const Duration _cache_duration = Duration(hours: 24);

  final bool enable_debug_logs;

  const PhoneCodeDetector({
    this.enable_debug_logs = false,
  });

  void _log(String message) {
    if (enable_debug_logs) {
      debugPrint('[PhoneCodeDetector] $message');
    }
  }

  /// Detects the user's country and returns the matching Country object with dial code.
  ///
  /// The detection follows this priority:
  /// 1. Cached result (if less than 24 hours old)
  /// 2. IP-based geolocation (using same APIs as language detection)
  /// 3. Falls back to first country in list (typically Afghanistan)
  Future<PhoneCodeDetectionResult> detect_phone_code() async {
    final prefs = await SharedPreferences.getInstance();

    // Check cache first
    final cached_result = _get_cached_result(prefs);
    if (cached_result != null) {
      _log('Using cached phone code: ${cached_result.country?.dial_code}');
      return cached_result;
    }

    // Try IP-based detection
    final ip_result = await _detect_from_ip();
    if (ip_result.success && ip_result.country != null) {
      _cache_result(prefs, ip_result.country!.alpha_2);
      return ip_result;
    }

    // Fallback to first country
    _log('Falling back to first country in list');
    return PhoneCodeDetectionResult.success(
      country: countries_list.first,
      source: 'fallback',
    );
  }

  PhoneCodeDetectionResult? _get_cached_result(SharedPreferences prefs) {
    final cached_country_code = prefs.getString(_cache_key_country_code);
    final cached_timestamp = prefs.getInt(_cache_key_timestamp);

    if (cached_country_code == null || cached_timestamp == null) {
      return null;
    }

    final cache_time = DateTime.fromMillisecondsSinceEpoch(cached_timestamp);
    final now = DateTime.now();

    if (now.difference(cache_time) > _cache_duration) {
      _log('Cache expired');
      return null;
    }

    final country = _find_country_by_alpha2(cached_country_code);
    if (country != null) {
      return PhoneCodeDetectionResult.success(
        country: country,
        source: 'cache',
      );
    }

    return null;
  }

  void _cache_result(SharedPreferences prefs, String country_code) {
    prefs.setString(_cache_key_country_code, country_code);
    prefs.setInt(_cache_key_timestamp, DateTime.now().millisecondsSinceEpoch);
    _log('Cached phone code for country: $country_code');
  }

  Future<PhoneCodeDetectionResult> _detect_from_ip() async {
    _log('Detecting phone code from IP...');

    final detector = IpLanguageDetector(enable_debug_logs: enable_debug_logs);
    final location_result = await detector.detect_country();

    if (!location_result.success || location_result.country_code == null) {
      _log('IP detection failed: ${location_result.error_message}');
      return PhoneCodeDetectionResult.failure(
        location_result.error_message ?? 'Failed to detect country from IP',
      );
    }

    final country = _find_country_by_alpha2(location_result.country_code!);
    if (country == null) {
      _log('Country not found for code: ${location_result.country_code}');
      return PhoneCodeDetectionResult.failure(
        'Country not found for code: ${location_result.country_code}',
      );
    }

    _log('Detected country: ${country.name} (${country.dial_code})');
    return PhoneCodeDetectionResult.success(
      country: country,
      source: 'ip_detection',
    );
  }

  /// Finds a country by its alpha-2 code (e.g., "US", "MX", "GB").
  Country? _find_country_by_alpha2(String alpha2_code) {
    final upper_code = alpha2_code.toUpperCase();
    try {
      return countries_list.firstWhere(
        (country) => country.alpha_2.toUpperCase() == upper_code,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Convenience function to detect phone code.
///
/// Returns the detected Country or the first country in the list as fallback.
Future<Country> detect_phone_country_code({bool enable_debug_logs = false}) async {
  final detector = PhoneCodeDetector(enable_debug_logs: enable_debug_logs);
  final result = await detector.detect_phone_code();
  return result.country ?? countries_list.first;
}
