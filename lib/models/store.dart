import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final String uid;
  final String? name;
  final String? owner;
  final String? address;
  final GeoPoint? coordinates;
  final String? category;
  final String? comment;
  final List? phone;
  final Timestamp? regDate;
  final List? photos;
  final String? uniqueCode;
  final int? color;

  Store({
    required this.uid,
    this.name,
    this.owner,
    this.address,
    this.coordinates,
    this.category,
    this.comment,
    this.phone,
    this.regDate,
    this.photos,
    this.uniqueCode,
    this.color,
  });

  factory Store.fromMap(Map<String, dynamic> mapData) {
    final String uid = mapData['uid'];
    final String name = mapData['name'];
    final String owner = mapData['owner'];
    final String address = mapData['address'];
    final GeoPoint coordinates = mapData["coordinates"];
    final String category = mapData['category'];
    final String comment = mapData['comment'];
    final List phone = mapData['phone'];
    final Timestamp regDate = mapData['regDate'];
    final List? photos = mapData['photos'];
    final String uniqueCode = mapData['uniqueCode'];
    final int? color = mapData['color'];

    return Store(
        uid: uid,
        name: name,
        owner: owner,
        address: address,
        coordinates: coordinates,
        category: category,
        comment: comment,
        phone: phone,
        regDate: regDate,
        photos: photos,
        uniqueCode: uniqueCode,
        color: color);
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "owner": owner,
      "address": address,
      "coordinates": coordinates,
      "category": category,
      "comment": comment,
      "phone": phone,
      "regDate": regDate,
      "photos": photos,
      "uniqueCode": uniqueCode,
      "color": color,
    };
  }
}
