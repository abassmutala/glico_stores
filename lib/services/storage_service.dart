import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<File?> compressImage(File originalImage) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalImage.absolute.path,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
      quality: 70,
    );
    return File(compressedFile!.path);
  }

  Future<String> uploadPhoto(File? file, String path) async {
    late String downloadUrl;

    Reference ref = _storage
        .ref()
        .child("assets/$path/${DateTime.now().millisecondsSinceEpoch}");

    UploadTask uploadTask = ref.putFile(File(file!.path));

    await uploadTask.whenComplete(() async {
      final downloadUrl0 = await ref.getDownloadURL();
      downloadUrl = downloadUrl0;
      return downloadUrl;
    });

    return downloadUrl;
  }
}
