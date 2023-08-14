import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker imagePicker = ImagePicker();

  Future<XFile?> _pickImage(ImageSource source) async {
    final XFile? image = await imagePicker.pickImage(
      source: source,
    );
    return image;
  }

  Future<List<XFile>> pickMultipleImages() async {
    return await imagePicker.pickMultiImage();
  }

  Future<XFile?> pickImageFromCamera() async {
    final XFile? image = await _pickImage(ImageSource.camera);
    return image;
  }

  Future<XFile?> pickImageFromGallery() async {
    final XFile? image = await _pickImage(ImageSource.gallery);
    return image;
  }
}
