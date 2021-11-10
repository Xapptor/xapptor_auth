import 'package:http/http.dart' as http;
import 'dart:convert';
import '../get_api_key.dart';

// AWS Rekognition Compare Faces

compare_face_images({
  required String source_image,
  required String target_image,
  required String similarity_threshold,
  required String service_url,
}) async {
  String access_key = await get_api_key(name: "access", organization: "aws");
  String secret_key = await get_api_key(name: "secret", organization: "aws");
  String region = await get_api_key(name: "region", organization: "aws");

  Map<String, String> headers = {};
  String body = jsonEncode({
    'source_image': source_image,
    'target_image': target_image,
    'similarity_threshold': similarity_threshold,
    'access_key': access_key,
    'secret_key': secret_key,
    'region': region,
  });

  http.Response rekognition_response = await http.post(
    Uri.parse(service_url),
    headers: headers,
    body: body,
  );
}
