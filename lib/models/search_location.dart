class SearchLocation {
  final String name;
  final String? region;
  final String? country;
  final List? coordinates;
  final String? geohash;
  final String? type;

  SearchLocation({
    required this.name,
    required this.region,
    required this.country,
    required this.coordinates,
    required this.geohash,
    this.type,
  });

  factory SearchLocation.fromMap(Map<String, dynamic> mapData) {
    // final String name = mapData['structured_formatting']['main_text'];
    // final String? region = mapData['structured_formatting']['secondary_text'];
    // final String? country = mapData['country'];
    // final List? coordinates = mapData['coordinates'];
    // final String? geohash = mapData['geohash'];
    // final String? type = mapData['types'][0];
    final String name = mapData['name'];
    final String? region = mapData['region'];
    final String? country = mapData['country'];
    final List? coordinates = mapData['coordinates'];
    final String? geohash = mapData['geohash'];
    final String? type = mapData['type'];
    return SearchLocation(
      name: name,
      region: region,
      country: country,
      coordinates: coordinates,
      geohash: geohash,
      type: type,
    );
  }
}
