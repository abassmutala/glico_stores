class DeviceInfo {
  final String platformVersion;
  final String imeiNo;
  final String modelName;
  final String manufacturer;
  final String apiLevel;
  final String deviceName;
  final String productName;
  final String cpuType;
  final String hardware;

  DeviceInfo({
    required this.platformVersion,
    required this.imeiNo,
    required this.modelName,
    required this.manufacturer,
    required this.apiLevel,
    required this.deviceName,
    required this.productName,
    required this.cpuType,
    required this.hardware,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> mapData) {
    final String platformVersion = mapData["platformVersion"];
    final String imeiNo = mapData["imeiNo"];
    final String modelName = mapData["modelName"];
    final String manufacturer = mapData["manufacturer"];
    final String apiLevel = mapData["apiLevel"];
    final String deviceName = mapData["deviceName"];
    final String productName = mapData["productName"];
    final String cpuType = mapData["cpuType"];
    final String hardware = mapData["hardware"];

    return DeviceInfo(
        platformVersion: platformVersion,
        imeiNo: imeiNo,
        modelName: modelName,
        manufacturer: manufacturer,
        apiLevel: apiLevel,
        deviceName: deviceName,
        productName: productName,
        cpuType: cpuType,
        hardware: hardware);
  }

  Map<String, dynamic> toMap() {
    return {
      "platformVersion": platformVersion,
      "imeiNo": imeiNo,
      "modelName": modelName,
      "manufacturer": manufacturer,
      "apiLevel": apiLevel,
      "deviceName": deviceName,
      "productName": productName,
      "cpuType": cpuType,
      "hardware": hardware,
    };
  }
}
