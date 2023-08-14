import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glico_stores/utils/enums.dart';

class Utilities {
  static String capitalize(String text) {
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  static String getNamefromEmail(String email) {
    return email.split('@')[0];
  }

  static String getNameInitials({required String firstname, String? surname}) {
    String firstnameInitial = firstname[0];
    String surnameInitial = surname != null ? surname[0] : '';
    if (surname == null) {
      return firstnameInitial.toUpperCase();
    }
    return '$firstnameInitial$surnameInitial'.toUpperCase();
  }

  static String getInitials(String name) {
    final names = name.split(" ");
    final name1Initial = names.length > 1 ? names[0][0] : names[0];
    final name2Initial = names.length > 1 ? names[names.length - 1][0] : "";
    return "$name1Initial$name2Initial".toUpperCase();
  }

  static String convertEnumToString(Enum value) {
    String convertedString = value.toString().split('.').last;
    return convertedString;
  }

  static InsuranceType convertStringToInsuranceTypeEnum(String value) {
    InsuranceType insuranceType = InsuranceType.values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => InsuranceType.business, //null
    );
    return insuranceType;
  }

  static String generateRandomColor() {
    const predefinedColours = [
      '0xFFF44336', //red
      '0xFFE91E63', //pink
      '0xFFFF9800', //orange
      '0xFFFF5722', //deepOrange
      '0xFF4CAF50', //green
      '0xFF009688', //teal
      '0xFF2196F3', //blue
      // 0xFF607D8B, //blueGrey
      '0xFF03A9F4', //lightBlue
      // 0xFF3F51B5, //indigo
      '0xFF9C27B0', //purple
      '0xFF00BCD4', //cyan
      // 0xFF9E9E9E, //grey
      '0xFF673AB7', //deepPurple
      // 0xFF795548, //brown
      '0xFFFFC107', //amber
      // 0xFF8BC34A, //lightGreen
    ];
    Random random = Random();
    return predefinedColours[random.nextInt(predefinedColours.length)];
  }

  static Color codeToColor(String colorCode) {
    return Color(
      int.parse(colorCode),
    ); //.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static generateRandom8DigitUid() {
    Random random = Random();
    String uuid = "";
    for (var i = 0; i < 8; i++) {
      uuid += random.nextInt(10).toString();
    }
    return uuid;
  }

  static String generateBusinessCode(String city) {
    // final String number = "$index".padLeft(5, "0");
    String number = generateRandom8DigitUid();
    final String cityCode = city.substring(0, 3).toUpperCase();
    final String code = "$cityCode$number";
    return code;
  }

  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // unit = the unit you desire for results
  //     where: 'M' is statute miles (default)
  //            'K' is kilometers
  //            'N' is nautical miles
  static String distance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
    required String unit,
  }) {
    double theta = lon1 - lon2;
    double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
    dist = acos(dist);
    dist = rad2deg(dist);
    dist = dist * 60 * 1.1515;
    if (unit == 'K') {
      dist = dist * 1.609344;
    } else if (unit == 'N') {
      dist = dist * 0.8684;
    }
    return dist.toStringAsFixed(2);
  }

  static double deg2rad(double deg) {
    return (deg * pi / 180.0);
  }

  static double rad2deg(double rad) {
    return (rad * 180.0 / pi);
  }

  // static Color generateRandomColor() {
  //   Random random = Random();
  //   double randomDouble = random.nextDouble();
  //   return Color((randomDouble * 0xFFFFFF).toInt()
  //   ).withOpacity(1.0);
  // }

  // static Color generateRandomColor() {
  //   Random random = Random();
  //   return Color.fromARGB(
  //     255,
  //     random.nextInt(256),
  //     random.nextInt(256),
  //     random.nextInt(256),
  //   );
  // }

  // static Future<PickedFile> pickImage(BuildContext context,
  //     {ImageSource source}) async {
  //   ImagePicker _picker;
  //   PickedFile _selectedImage = await _picker.getImage(source: source);
  //   // return compressImage(imageToCompress: selectedImage);
  //   _selectedImage != null
  //       ? Navigator.of(context)
  //           .pushNamed(CropImageRoute, arguments: File(_selectedImage.path))
  //       : Navigator.of(context).pop();
  //   return _selectedImage;
  // }

  // static Future<File> compressImage({File imageToCompress}) async {
  //   final tempDir = await getTemporaryDirectory();
  //   final path = tempDir.path;

  //   int randomName = Random().nextInt(10000);

  //   Image.Image image = Image.decodeImage(imageToCompress.readAsBytesSync());
  //   Image.copyResize(image, width: 500, height: 500);

  //   return new File('$path/img_$randomName.jpg')
  //     ..writeAsBytesSync(Image.encodeJpg(image, quality: 85));
  // }

  // Future saveToDocuments(File imageFile) async {
  //   final appDir = await getApplicationDocumentsDirectory();
  //   final fileName = basename(imageFile.path);
  //   final savedImage = await imageFile.copy('${appDir.path}/$fileName');
  // }
}
