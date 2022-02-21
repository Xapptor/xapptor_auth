import 'package:http/http.dart' as http;
import 'dart:convert';

// AWS Rekognition Compare Faces

Future<bool> compare_faces_with_remote_service({
  required String source_image_base64,
  required String target_image_base64,
  double similarity_threshold = 80.0,
  String region = "us-east-1",
}) async {
  String endpoint =
      'https://bfzxipfgn5.execute-api.us-east-1.amazonaws.com/default/compare_faces';

  Map<String, String> headers = {
    'Content-Type': "application/json",
  };

  Map body = {
    "source_bytes": source_image_base64,
    "target_bytes": target_image_base64,
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
