import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:xapptor_logic/get_temporary_file_from_local.dart';
import 'package:xapptor_me/fe.dart';

upload_new_face_id_file({
  required Uint8List source_bytes,
  required User current_user,
  required Function callback,
}) async {
  FE fe = FE();
  Uint8List encrypted_bytes = fe.encrypt_bytes(
    b: source_bytes,
    k: current_user.uid,
    inverse: false,
  );

  File source_file = await get_temporary_file_from_local(
    bytes: encrypted_bytes,
    name: "temp_image_1.jpeg",
  );

  String timeStamp = DateTime.now().toIso8601String();

  Reference face_id_ref = FirebaseStorage.instance
      .ref()
      .child('face_id')
      .child('/' + current_user.uid)
      .child('/${timeStamp}.jpg');

  final metadata = SettableMetadata(
    contentType: 'image/jpeg',
    customMetadata: {'picked-file-path': source_file.path},
  );

  face_id_ref.putFile(source_file, metadata).then((p0) {
    source_file.delete();
  });

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
      .child('face_id')
      .child('/' + current_user.uid)
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
      .child('face_id')
      .child('/' + current_user.uid)
      .listAll();

  result.items.shuffle();
  return await result.items.first.getDownloadURL();
}
