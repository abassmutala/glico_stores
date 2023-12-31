import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:glico_stores/constants/api_path.dart';
import 'package:glico_stores/models/business.dart';
import 'package:glico_stores/models/user.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid}); // : assert(uid != null);

  final FirebaseFirestore _service = FirebaseFirestore.instance;
  final Settings disableCaching = const Settings(persistenceEnabled: false);
  // final Geoflutterfire geo = Geoflutterfire();

  /* General CRUD Methods */

  Future<void> _setData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final DocumentReference reference = _service.doc(path);
      await reference.set(data);
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code, message: e.toString());
    }
  }

  Future<String> _addData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final reference = _service.collection(path);
      final docData = await reference.add(data);
      return docData.id;
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code, message: e.toString());
    }
  }

  Future<List<T>> _collectionFuture<T>({
    required String path,
    required T Function(Map<String, dynamic> data) builder,
  }) async {
    final CollectionReference<Map<String, dynamic>> reference =
        _service.collection(path);
    final QuerySnapshot<Map<String, dynamic>> snapshots = await reference.get();
    final docs = snapshots.docs.map((e) => builder(e.data())).toList();
    // final docs = snapshots.docs.map((e) => e.data()).toList();
    return docs;
  }

  Stream<List<T>> _collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data) builder,
  }) {
    final reference = _service.collection(path);
    final snapshots = reference.snapshots();
    return snapshots.map(
      (snapshot) => snapshot.docs
          .map(
            (document) => builder(document.data()),
          )
          .toList(),
    );
  }

  Future<void> _updateData({
    required String documentPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final reference = _service.doc(documentPath);
      await reference.update(data);
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.toString(),
      );
    }
  }

  Future<void> _deleteDoc({
    required String documentPath,
  }) async {
    try {
      final reference = _service.doc(documentPath);
      await reference.delete();
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.toString(),
      );
    }
  }

  /* User */
  Future<void> createProfile(User user) async {
    await _setData(
      path: APIPath.profile(user.uid),
      data: user.toMap(),
    );
  }

  Future<User> getUser(String? userId) async {
    try {
      var userData = await _service.doc(APIPath.profile(userId!)).get();
      return User.fromMap(
        userData.data()!,
      );
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code, message: e.toString());
    }
  }

  Future deleteUser(String uid) async {
    await _deleteDoc(documentPath: "${APIPath.users()}/$uid}");
  }

  Future<bool> checkIfCredentialsMatch(
      User? user, String uniqueCode, String deviceID) async {
    //  final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final User userData = await getUser(userId);

      final storedUniqueId = userData.uniqueCode;
      final storedDeviceID = userData.deviceInfo!["id"];

      if (uniqueCode == storedUniqueId && deviceID == storedDeviceID) {
        // Update the session timestamp to extend it by 72 hours
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        await _updateData(documentPath: "users/${user.uid}", data: {'lastLoginTimestamp': currentTime});

        return true;
      }
    }

    return false;
  }

  Future updateRegisteredBusinessesForUser(
      String uid, String businessId) async {
    try {
      await _updateData(documentPath: APIPath.profile(uid), data: {
        "addedBusinesses": FieldValue.arrayUnion([businessId]),
      });
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message,
      );
    }
  }

  // Stream<List<T>> nearBysStream<T>({
  //   required UserLocation userLocation,
  //   required String path,
  //   required T Function(Map<String, dynamic> data) builder,
  // }) {
  //   GeoFirePoint center = geo.point(
  //     latitude: userLocation.latitude!,
  //     longitude: userLocation.longitude!,
  //   );
  //   final CollectionReference<Map<String, dynamic>> reference =
  //       _service.collection(path);

  //   double radius = 2;
  //   String field = 'position';

  //   final snapshots = geo.collection(collectionRef: reference).within(
  //         center: center,
  //         radius: radius,
  //         field: field,
  //       );
  //   return snapshots.map((docs) {
  //     return docs.map((doc) => builder(doc.data()!)).toList();
  //   });
  // }

/* Business */
  Future<String> createBusinessProfile(Business business) async {
    final uid = await _addData(
      path: APIPath.businesses(),
      data: business.toJson(),
    );
    return uid;
  }

  Future<void> updateBusinessUid(uid) async {
    await _updateData(
        documentPath: APIPath.businessProfile(uid), data: {"uid": uid});
  }

  Future<List<Map<String, dynamic>>> getBusinessesCategories() async {
    return await _collectionFuture(
      path: APIPath.businessCategories(),
      builder: (mapData) => {
        "name": mapData["name"],
        "value": mapData["value"],
      },
    );
  }

  Future<String> getBusinessesCategory(String value) async {
    try {
      final data = await _service
          .collection(APIPath.businessCategories())
          .where("value", isEqualTo: value)
          .get();
      final String kV = await data.docs.first.data()["name"];
      return kV;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.toString(),
      );
    }
  }

  Future<List<Business>> getBusinessesList() async {
    return await _collectionFuture(
      path: APIPath.businesses(),
      builder: (mapData) => Business.fromMap(mapData),
    );
  }

  Stream<List<Business>?> getBusinessesStream() {
    final reference = _service.collection(APIPath.businesses()).orderBy('regDate', descending: true);
    final snapshots = reference.snapshots();
    return snapshots.map(
      (snapshot) => snapshot.docs
          .map(
            (document) => Business.fromMap(document.data()),
          )
          .toList(),
    );
    // return _collectionStream(
    //   path: , builder: (data) => Business.fromMap(data));
  }

  Stream<List<Map<String, dynamic>>> getCategoriesStream() {
    final data = _collectionStream(
        path: APIPath.businessCategories(),
        builder: (data) => {
              "name": data["name"],
              "value": data["value"],
            });
    return data;
  }

  Future<Business> getBusiness(String uid) async {
    try {
      final data = await _service.doc(APIPath.businessProfile(uid)).get();
      return Business.fromMap(
        data.data()!,
      );
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.toString(),
      );
    }
  }

  Future<void> updateBusinessData(String uid, Map<String, dynamic> data) async {
    await _updateData(
      documentPath: APIPath.businessProfile(uid),
      data: data,
    );
  }

  Future<void> deleteBusiness(String uid) async {
    await _deleteDoc(
      documentPath: APIPath.businessProfile(uid),
    );
  }

/* User */
// user data from snapshots
  User _userDataFromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return User.fromMap(snapshot.data()!);
  }

  // get user doc stream
  Stream<User> get userData {
    return _service
        .doc(APIPath.profile(uid!))
        .snapshots()
        .map(_userDataFromSnapshot);
  }

/* Stays */
  Future<List<Map<String, dynamic>>?> getStayTypes() async {
    final CollectionReference<Map<String, dynamic>> reference =
        _service.collection('stay_types/');
    final QuerySnapshot<Map<String, dynamic>> snapshots = await reference.get();
    final List<Map<String, dynamic>> stayTypesData = snapshots.docs.map((e) {
      return {
        'name': e.data()['name'],
        'photo': e.data()['photo'],
      };
    }).toList();
    return stayTypesData;
  }

  // Future<bool> checkIfFavouriteExists(String uid, String assetId) async {
  //   try {
  //     final CollectionReference<Map<String, dynamic>> favouritesCollection =
  //         _service.collection('/users/$uid/favourites/');
  //     final QuerySnapshot<Map<String, dynamic>> favData =
  //         await favouritesCollection
  //             .where('asset_id', isEqualTo: assetId)
  //             .get();
  //     if (favData == null) {
  //       return false;
  //     } else if (favData.docs.isNotEmpty) {
  //       debugPrint(favData.docs.single.data()['asset_id']);
  //       return true;
  //     }
  //     return false;
  //   } on PlatformException catch (e) {
  //     throw PlatformException(
  //       code: e.code,
  //       message: e.toString(),
  //     );
  //   }
  // }
}
