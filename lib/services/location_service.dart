import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:glico_stores/models/business_location.dart';
import 'package:http/http.dart' as http;
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  late bool _serviceEnabled;
  late LocationPermission _permissionStatus;
  Position? _locationData;
  BusinessLocation? currentPosition;
  BusinessLocation? _businessLocation;
  // CameraPosition? cameraPosition;
  BusinessLocation? locationCoordinates;
  final geocoding.GeocodingPlatform _geocodingInstance =
      geocoding.GeocodingPlatform.instance;

  Future initialisePermissions() async {
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      return;
    }

    _permissionStatus = await Geolocator.checkPermission();
    if (_permissionStatus == LocationPermission.denied) {
      _permissionStatus = await Geolocator.requestPermission();
      if (_permissionStatus != LocationPermission.deniedForever) {
        return;
      }

      if (_permissionStatus == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return;
      }
    }
  }

  Future<BusinessLocation> getCurrentLocation() async {
    try {
      await initialisePermissions();
      _locationData = await Geolocator.getCurrentPosition();
      locationCoordinates = BusinessLocation(
        latitude: _locationData?.latitude,
        longitude: _locationData?.longitude,
      );
      debugPrint(
          "Coordinates: ${_locationData?.latitude} ${_locationData?.longitude}");
      return locationCoordinates!;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.toString(),
      );
    }
  }

  Future<BusinessLocation?> convertToAddress(
    double lat,
    double lng,
  ) async {
    String apiKey = "AIzaSyDI0LaXHJA3ZwjmwgS-FKXyK6xGkai-kuY";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey&enable_address_descriptor=true";

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse =
          jsonDecode(response.body);
      final location = BusinessLocation.fromMap(jsonResponse);
      print("service Location: $jsonResponse");
      print("service Location: ${location.latitude}  ${location.longitude}");
      return location;
    } else {
      throw ("Request failed with status: ${response.statusCode}");
    }
  }

  // void locateUserOnMap() async {
  //   final _locationCoordinates = await getCurrentLocation().then(
  //       (userLocation) => BusinessLocation(
  //           latitude: userLocation.latitude,
  //           longitude: userLocation.longitude));
  //   cameraPosition = CameraPosition(
  //     target: LatLng(
  //         _locationCoordinates.latitude!, _locationCoordinates.longitude!),
  //     zoom: 14.0,
  //   );
  //   // return cameraPosition;
  // }

  Future<BusinessLocation?> getAddressFromCoordinates(
      {BusinessLocation? currentPosition}) async {
    try {
      final currentPosition0 = currentPosition ?? await getCurrentLocation();
      List<geocoding.Placemark> placemarks =
          await _geocodingInstance.placemarkFromCoordinates(
        currentPosition0.latitude!,
        currentPosition0.longitude!,
      );
      geocoding.Placemark place = placemarks[0];
      _businessLocation = BusinessLocation(
        latitude: currentPosition0.latitude,
        longitude: currentPosition0.longitude,
        subLocality: place.subLocality,
        city: place.locality,
        region: place.administrativeArea,
        country: place.country,
      );
      debugPrint('Country: ${place.country}');
      debugPrint('administrativeArea: ${place.administrativeArea}');
      debugPrint('locality: ${place.locality}');
      debugPrint('subLocality: ${place.subLocality}');
      return _businessLocation;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.toString(),
      );
    }
  }

  Future<BusinessLocation> getCoordinatesFromAddress(String address) async {
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final output = locations[0];
        currentPosition = BusinessLocation(
            latitude: output.latitude, longitude: output.longitude);
        debugPrint(
            'CurrentPosition: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
      }
      return currentPosition!;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.toString(),
      );
    }
    // return currentPosition;
  }
}
