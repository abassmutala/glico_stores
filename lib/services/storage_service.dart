import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPhoto(File? file, String path) async {
    late String downloadUrl;

    Reference ref = _storage.ref().child("assets/$path/${DateTime.now()}");

    UploadTask uploadTask = ref.putFile(File(file!.path));

    await uploadTask.whenComplete(() async {
      final downloadUrl0 = await ref.getDownloadURL();
      downloadUrl = downloadUrl0;
      return downloadUrl;
    });

    return downloadUrl;
  }
}
