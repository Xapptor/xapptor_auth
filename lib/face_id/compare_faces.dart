import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

// AWS Rekognition Compare Faces

Future<String> get_base64_image(String src) async {
  http.Response response = await http.get(
    Uri.parse(src),
  );

  Uint8List? bytes = response.bodyBytes;
  return base64.encode(bytes);
}

Future<bool> compare_faces({
  required String source_image,
  required String target_image,
  required double similarity_threshold,
  required String region,
}) async {
  String source_bytes = await get_base64_image(source_image);
  String target_bytes = await get_base64_image(target_image);

  String endpoint =
      'https://bfzxipfgn5.execute-api.us-east-1.amazonaws.com/default/compare_faces';

  Map<String, String> headers = {
    'Content-Type': "application/json",
  };

  Map body = {
    "source_bytes": source_bytes,
    "target_bytes": target_bytes,
    "similarity_threshold": similarity_threshold,
    "aws_region": region,
  };

  http.Response response = await http.post(
    Uri.parse(endpoint),
    headers: headers,
    body: json.encode(body),
  );

  Map response_body = jsonDecode(response.body);

  double similarity = 0;
  bool face_match = false;

  List<dynamic> face_matches = response_body["FaceMatches"] as List<dynamic>;

  if (face_matches.length > 0) {
    similarity = face_matches[0]["Similarity"];
    face_match = similarity > 92;
  }

  print("similarity: " + similarity.toString());
  print("face_match: " + face_match.toString());

  return face_match;
}
