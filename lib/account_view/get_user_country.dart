import 'package:xapptor_ui/values/country/country.dart';
import 'package:geocoding/geocoding.dart';
import 'package:xapptor_logic/request_position.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Country> get_user_country() async {
  List<Placemark> address_from_position = await get_address_from_position();

  if (address_from_position.isNotEmpty) {
    Country country = countries_list.firstWhere(
      (country) => country.alpha_2.toLowerCase() == address_from_position.first.isoCountryCode?.toLowerCase(),
      orElse: () => get_usa_country(),
    );
    return country;
  } else {
    String? country_code = await _get_country_code_from_ip();

    if (country_code != null) {
      Country country = countries_list.firstWhere(
        (country) => country.alpha_2.toLowerCase() == country_code.toLowerCase(),
        orElse: () => get_usa_country(),
      );
      return country;
    } else {
      return get_usa_country();
    }
  }
}

Country get_usa_country() {
  return countries_list.firstWhere(
    (country) => country.alpha_3.toLowerCase() == "usa",
    orElse: () => countries_list.first,
  );
}

Future<String?> _get_country_code_from_ip() async {
  final response = await http.get(Uri.parse('https://ipapi.co/json/'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['country_code'];
  } else {
    return null;
  }
}
