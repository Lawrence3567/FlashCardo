import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageApi {
  static Future<String> uploadFile(String destination, File file) async {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      final task = ref.putFile(file);
      String url;
      url = await (await task).ref.getDownloadURL();
      return url;
    } on FirebaseException {
      return null;
    }
  }
}
