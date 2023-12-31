import 'package:cloud_firestore/cloud_firestore.dart';

class Business {
  final String uid;
  final String? name;
  final String? owner;
  // final List? aka;
  final String? address;
  final GeoPoint? coordinates;
  final String? category;
  final String? comment;
  // final String? chain;
  final List? phone;
  final Timestamp? regDate;
  // final String? region;
  // final String? city;
  // final String? email;
  // final String? website;
  final List? photos;
  final String? uniqueCode;
  final String? insuranceType;
  final double? estimatedAssetValue;
  final double? premium;
  final bool? insured;
  // final String? landmark;
  // final bool? verified;
  final int? color;

  Business({
    required this.uid,
    this.name,
    this.owner,
    // this.aka,
    this.address,
    this.coordinates,
    this.category,
    this.comment,
    // this.chain,
    this.phone,
    this.regDate,
    // this.region,
    // this.city,
    // this.email,
    // this.website,
    this.photos,
    // this.landmark,
    // this.verified,
    this.uniqueCode,
    this.insuranceType,
    this.estimatedAssetValue,
    this.premium,
    this.insured,
    this.color,
  });

  factory Business.fromMap(Map<String, dynamic> mapData) {
    final String uid = mapData['uid'];
    final String name = mapData['name'];
    final String owner = mapData['owner'];
    // final List aka = mapData['aka'];
    final String address = mapData['address'];
    final GeoPoint coordinates = mapData["coordinates"];
    final String category = mapData['category'];
    final String comment = mapData['comment'];
    // final String chain = mapData['chain'];
    final List phone = mapData['phone'];
    final Timestamp regDate = mapData['regDate'];
    // final String region = mapData['region'];
    // final String city = mapData['city'];
    // final String email = mapData['email'];
    // final String website = mapData['website'];
    final List? photos = mapData['photos'];
    // final String landmark = mapData['landmark'];
    // final bool verified = mapData['verified'];
    final String uniqueCode = mapData['uniqueCode'];
    final String? insuranceType = mapData['insuranceType'];
    final double? estimatedAssetValue = mapData["estimatedAssetValue"];
    final double? premium = mapData["premium"];
    final bool? insured = mapData['insured'];
    final int? color = mapData['color'];

    return Business(
      uid: uid,
      name: name,
      owner: owner,
      address: address,
      coordinates: coordinates,
      category: category,
      comment: comment,
      // chain: chain,
      phone: phone,
      regDate: regDate,
      // region: region,
      // city: city,
      // email: email,
      // website: website,
      photos: photos,
      // landmark: landmark,
      // verified: verified,
      uniqueCode: uniqueCode,
      insuranceType: insuranceType,
      estimatedAssetValue: estimatedAssetValue,
      premium: premium,
      insured: insured,
      color: color
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "owner": owner,
      // "aka": aka,
      "address": address,
      "coordinates": coordinates,
      "category": category,
      "comment": comment,
      // "chain": chain,
      "phone": phone,
      "regDate": regDate,
      // "region": region,
      // "city": city,
      // "email": email,
      // "website": website,
      "photos": photos,
      // "landmark": landmark,
      // "verified": verified,
      "uniqueCode": uniqueCode,
      "insuranceType": insuranceType,
      "estimatedAssetValue": estimatedAssetValue,
      "premium": premium,
      "insured": insured,
      "color": color,
    };
  }
}
