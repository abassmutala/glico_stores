import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:glico_stores/constants/credentials.dart';
import 'package:glico_stores/models/business_location.dart';
import 'package:glico_stores/models/search_location.dart';
import 'package:http/http.dart' as http;

class PlaceService {
  final key = 'AIzaSyDOdws1DuSMaRV359WDxjg5JydJV46v8HA';
  final String sessionToken;

  PlaceService(this.sessionToken);

  Future<List<SearchLocation>> getLocationSuggestions(
      {required String input, required String lang}) async {
    // String type = 'regions'; //'(regions)'
    String components = 'country:gh';
    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=$lang&components=$components&key=$key&sessiontoken=$sessionToken';
    //    'https://maps.googleapis.com/maps/api/js?key=$key&libraries=places'
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final request = json.decode(response.body);
      if (request['status'] == 'OK') {
        // compose suggestions in a list

        var result = request['predictions'] as List;
        // var pr = result.where((element) => false)
        return result.map((place) => SearchLocation.fromMap(place)).toList();
      }
      if (request['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(request['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}

// class Place {
//   String streetNumber;
//   String street;
//   String city;
//   String zipCode;

//   Place({
//     this.streetNumber,
//     this.street,
//     this.city,
//     this.zipCode,
//   });

//   @override
//   String toString() {
//     return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
//   }
// }

class Suggestion {
  final String? placeId;
  final String? name;
  final String? city;
  final String? country;

  Suggestion({this.placeId, this.name, this.city, this.country});

  @override
  String toString() {
    return 'Suggestion(name: $name, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  final client = http.Client();

  PlaceApiProvider(this.sessionToken);

  final String sessionToken;

  // static const String androidKey = placesApiKey;
  // static const String iosKey = placesApiKey;
  final apiKey = placesApiKey; //Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String type = '(regions)';
    String components = 'country:gh';
    final request =
        '$baseUrl?input=$input&language=$lang&components=$components&type=$type&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions'].map<Suggestion>((place) {
          debugPrint(place['structured_formatting']['main_text']);
          return Suggestion(
              placeId: place['place_id'],
              name: place['description'],
              city: place['structured_formatting']['main_text'],
              country: place['structured_formatting']['secondary_text']);
        }).toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<BusinessLocation> getPlaceCoordinatesFromPlaceId(
      String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return result['result']["geometry"]["location"]
            .map<BusinessLocation>(
              (location) => BusinessLocation(
                  latitude: location['lat'], longitude: location['lng']),
            )
            .toList();
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  // Future<Place> getPlaceDetailFromId(String placeId) async {
  //   final request =
  //       'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=$apiKey&sessiontoken=$sessionToken';
  //   final response = await client.get(Uri.parse(request));
  //   if (response.statusCode == 200) {
  //     final result = json.decode(response.body);
  //     if (result['status'] == 'OK') {
  //       final components =
  //           result['result']['address_components'] as List<dynamic>;
  //       // build result
  //       final place = Place();
  //       components.forEach((c) {
  //         final List type = c['types'];
  //         if (type.contains('street_number')) {
  //           place.streetNumber = c['long_name'];
  //         }
  //         if (type.contains('route')) {
  //           place.street = c['long_name'];
  //         }
  //         if (type.contains('locality')) {
  //           place.city = c['long_name'];
  //         }
  //         if (type.contains('postal_code')) {
  //           place.zipCode = c['long_name'];
  //         }
  //       });
  //       return place;
  //     }
  //     throw Exception(result['error_message']);
  //   } else {
  //     throw Exception('Failed to fetch suggestion');
  //   }
  // }
}
