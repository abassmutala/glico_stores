import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:trilo/models/user.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
import '/constants/api_path.dart';
import '/models/store.dart';

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
      return User.fromMap(userData.data()!);
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code, message: e.toString());
    }
  }

/* Store */
  Future<String> createStoreProfile(Store store) async {
    final uid = await _addData(
      path: APIPath.stores(),
      data: store.toJson(),
    );
    return uid;
  }

  Future<void> updateStoreUid(uid) async {
    await _updateData(
        documentPath: APIPath.storeProfile(uid), data: {"uid": uid});
  }

  Future<List<Map<String, dynamic>>> getStoreCategories() async {
    return await _collectionFuture(
      path: APIPath.storeCategories(),
      builder: (mapData) => {
        "name": mapData["name"],
        "value": mapData["value"],
      },
    );
  }

  Future<String> getStoresCategory(String value) async {
    try {
      final data = await _service
          .collection(APIPath.storeCategories())
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

  Future<List<Store>> getStoresList() async {
    return await _collectionFuture(
      path: APIPath.stores(),
      builder: (mapData) => Store.fromMap(mapData),
    );
  }

  Stream<List<Store>?> getStoresStream() {
    final reference = _service
        .collection(APIPath.stores())
        .orderBy('regDate', descending: true);
    final snapshots = reference.snapshots();
    return snapshots.map(
      (snapshot) => snapshot.docs
          .map(
            (document) => Store.fromMap(document.data()),
          )
          .toList(),
    );
    // return _collectionStream(
    //   path: , builder: (data) => Store.fromMap(data));
  }

  Stream<List<Map<String, dynamic>>> getCategoriesStream() {
    final data = _collectionStream(
        path: APIPath.storeCategories(),
        builder: (data) => {
              "name": data["name"],
              "value": data["value"],
            });
    return data;
  }

  Future<Store> getStore(String uid) async {
    try {
      final data = await _service.doc(APIPath.storeProfile(uid)).get();
      return Store.fromMap(
        data.data()!,
      );
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.toString(),
      );
    }
  }

  Future<void> updateStoreData(String uid, Map<String, dynamic> data) async {
    await _updateData(
      documentPath: APIPath.storeProfile(uid),
      data: data,
    );
  }

  Future<void> deleteStore(String uid) async {
    await _deleteDoc(
      documentPath: APIPath.storeProfile(uid),
    );
  }
}
