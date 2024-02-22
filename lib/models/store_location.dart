class StoreLocation {
  double? latitude;
  double? longitude;
  final double? altitude;
  final double? speed;

  /// The estimated horizontal accuracy of the position in meters.
  final double? accuracy;

  /// The heading in which the device is traveling in degrees.
  final double? heading;

  /// The floor specifies the floor of the building on which the device is
  /// located.
  final int? floor;

  /// The estimated speed accuracy of this position, in meters per second.
  final double? speedAccuracy;
  final String? subLocality;
  final String? city;
  final String? region;
  final String? country;

  StoreLocation({
    this.latitude,
    this.longitude,
    this.altitude,
    this.speed,
    this.accuracy,
    this.heading,
    this.floor,
    this.speedAccuracy,
    this.subLocality,
    this.city,
    this.region,
    this.country,
  });

  factory StoreLocation.fromMap(Map<String, dynamic> mapData) {
    double? latitude = mapData['latitude'];
    double? longitude = mapData['longitude'];
    final double? altitude = mapData['altitude'];
    final double? speed = mapData['speed'];
    final double? accuracy = mapData['accuracy'];
    final double? heading = mapData['heading'];
    final int? floor = mapData['floor'];
    final double? speedAccuracy = mapData['speed_accuracy'];
    final String? subLocality = mapData['sub_locality'];
    final String? city = mapData['city'];
    final String? region = mapData['region'];
    final String? country = mapData['country'];
    return StoreLocation(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      speed: speed,
      accuracy: accuracy,
      heading: heading,
      floor: floor,
      speedAccuracy: speedAccuracy,
      subLocality: subLocality,
      city: city,
      region: region,
      country: country,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'accuracy': accuracy,
      'heading': heading,
      'floor': floor,
      'speed_accuracy': speedAccuracy,
      'sub_locality': subLocality,
      'city': city,
      'region': region,
      'country': country,
    };
  }
}
