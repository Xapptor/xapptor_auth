import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:xapptor_api_key/initial_values.dart';

upload_new_face_id_file({
  required Uint8List source_bytes,
  required User current_user,
  required Function callback,
}) async {
  Uint8List e_b = [] as Uint8List;

  if (e_b_f_au != null) {
    e_b = e_b_f_au!(
      b: source_bytes,
      k: current_user.uid,
      inverse: false,
    );
  } else {
    e_b = source_bytes;
  }

  String timeStamp = DateTime.now().toIso8601String();

  Reference face_id_ref = FirebaseStorage.instance
      .ref()
      .child('users')
      .child('/' + current_user.uid)
      .child('/face_id')
      .child('/${timeStamp}.jpg');

  final metadata = SettableMetadata(
    contentType: 'image/jpeg',
  );

  face_id_ref.putData(e_b, metadata);

  check_user_face_id_files_length(
    current_user: current_user,
    callback: callback,
  );
}

check_user_face_id_files_length({
  required User current_user,
  required Function callback,
}) async {
  ListResult result = await FirebaseStorage.instance
      .ref()
      .child('users')
      .child('/' + current_user.uid)
      .child('/face_id')
      .listAll();

  if (result.items.length > 3) {
    result.items.sort((a, b) => a.name.compareTo(b.name));

    for (var i = 0; i <= (result.items.length - 3); i++) {
      await result.items[i].delete();
      if (i <= (result.items.length - 3)) {
        callback();
      }
    }
  } else {
    callback();
  }
}

Future<String> get_random_face_id_file_url({
  required User current_user,
}) async {
  ListResult result = await FirebaseStorage.instance
      .ref()
      .child('users')
      .child('/' + current_user.uid)
      .child('/face_id')
      .listAll();

  result.items.shuffle();
  return await result.items.first.getDownloadURL();
}
