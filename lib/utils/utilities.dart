import 'dart:math';

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import 'package:uuid/uuid.dart';

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
    if (!name.contains(" ")) {
      return name[0].toUpperCase();
    }
    final names = name.split(" ");
    final name1Initial = names.length > 1 ? names[0][0] : names[0];
    final name2Initial = names.length > 1 ? names[names.length - 1][0] : "";
    return "$name1Initial$name2Initial".toUpperCase();
  }

  static String convertEnumToString(Enum value) {
    String convertedString = value.toString().split('.').last;
    return convertedString;
  }

  static String convertStoreCategoryToText(String categoryCode) {
    final Map<String, String> categories = {
      "other": "Other",
      "wholesaler": "Wholesaler",
      "retailer": "Retailer",
      "distributor": "Distributor",
      "corner_shop": "Corner shop",
    };

    return categories[categoryCode] ?? categoryCode;
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

  static String formatNumber(String val) {
    if (val.isEmpty) return '';

    // Remove all non-digit characters except the last dot (if any)
    String sanitizedValue = val.replaceAll(RegExp(r'[^\d.]'), '');

    // Parse the sanitized value to a number
    double number = double.tryParse(sanitizedValue) ?? 0;

    // Format the number with commas
    return NumberFormats.formattedNumberFormat.format(number);
  }

  // static String formatNumber(String value) {
  //   if (value.isEmpty) return '';

  //   // Remove all non-digit characters except the last dot (if any)
  //   String sanitizedValue = value.replaceAll(RegExp(r'[^\d.]'), '');

  //   // Split the value into integer and decimal parts
  //   List<String> parts = sanitizedValue.split('.');
  //   String integerPart = parts[0];
  //   String decimalPart = parts.length > 1 ? parts[1] : '';

  //   // Add commas to the integer part
  //   String formattedInteger = '';
  //   for (int i = 0; i < integerPart.length; i++) {
  //     formattedInteger += integerPart[i];
  //     if ((integerPart.length - i - 1) % 3 == 0 &&
  //         i != integerPart.length - 1) {
  //       formattedInteger += ',';
  //     }
  //   }

  //   // Combine integer and decimal parts
  //   String formattedValue = formattedInteger;
  //   if (decimalPart.isNotEmpty) {
  //     formattedValue += '.$decimalPart';
  //   }

  //   return formattedValue;
  // }
  static String generateUserUuid() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  static int generateUniqueCode(String text) {
    // Remove all non-digit characters (letters) from the string
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit it to the first 6 numbers
    final result = digitsOnly.substring(0, 6);

    return int.parse(result);
  }

  static generateRandom8DigitUid() {
    Random random = Random();
    String uuid = "";
    for (var i = 0; i < 8; i++) {
      uuid += random.nextInt(10).toString();
    }
    return uuid;
  }

  static String generateStoreCode(String city) {
    // final String number = "$index".padLeft(5, "0");
    String number = generateRandom8DigitUid();
    final String cityCode = city.substring(0, 3).toUpperCase();
    final String code = "$cityCode$number";
    return code;
  }

  // static getDeviceInfo() async {
  //   try {
  //     final platformVersion = await DeviceInformation.platformVersion;
  //     final imeiNo = await DeviceInformation.deviceIMEINumber;
  //     final modelName = await DeviceInformation.deviceModel;
  //     final manufacturer = await DeviceInformation.deviceManufacturer;
  //     final apiLevel = await DeviceInformation.apiLevel;
  //     final deviceName = await DeviceInformation.deviceName;
  //     final productName = await DeviceInformation.productName;
  //     final cpuType = await DeviceInformation.cpuName;
  //     final hardware = await DeviceInformation.hardware;
  //     final deviceInfo = DeviceInfo(
  //       platformVersion: platformVersion,
  //       imeiNo: imeiNo,
  //       modelName: modelName,
  //       manufacturer: manufacturer,
  //       apiLevel: apiLevel,
  //       deviceName: deviceName,
  //       productName: productName,
  //       cpuType: cpuType,
  //       hardware: hardware,
  //     );
  //     return deviceInfo;
  //   } on PlatformException catch (e) {
  //     debugPrint(e.message);
  //   }
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
