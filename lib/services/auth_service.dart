import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';
import 'package:glico_stores/models/user.dart';
import 'package:glico_stores/services/database_service.dart';
import 'package:glico_stores/utils/utilities.dart';
import 'package:uuid/uuid.dart';

abstract class AuthBase {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<User> createAccount({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required Map deviceInfo,
  });
  Future<User> signInWithEmail(
    String email,
    String password,
  );
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

class AuthService implements AuthBase {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final DatabaseService db = DatabaseService();

  Future _populateCurrentUser(auth.User? user) async {
    if (user != null) {
      // User _currentUser =
      await db.getUser(user.uid);
    }
  }

  User? _userFromFirebase(auth.User? user) {
    return user != null
        ? User(
            uid: user.uid,
            email: user.email,
            dateJoined: user.metadata.creationTime!.toString(),
            phone: user.phoneNumber,
          )
        : null;
  }

  @override
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  Future<bool> checkIfUserisLoggedIn() async {
    return _auth.currentUser == null;
  }

  Future<User> signInAnonymously() async {
    try {
      final auth.UserCredential credential = await _auth.signInAnonymously();

      auth.User user = credential.user!;

      await _populateCurrentUser(user);
      return _userFromFirebase(user)!;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message,
      );
    }
  }

  @override
  Future<User> createAccount({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required Map deviceInfo
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      final uniqueCode = const Uuid().v4();

      User newUser = User(
        uid: user.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        color: Utilities.generateRandomColor(),
        dateJoined: user.metadata.creationTime.toString(),
        addedBusinesses: [],
        deviceInfo: deviceInfo,
        uniqueCode: Utilities.generateUniqueCode(uniqueCode)
      );

      await DatabaseService().createProfile(newUser);

      // TODO: Send unique credential

      return _userFromFirebase(user)!;
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message,
      );
    }
  }

  @override
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = credential.user;
      await _populateCurrentUser(user);
      return _userFromFirebase(user)!;
    } on auth.FirebaseException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message,
      );
    }
  }

  @override
  Future signOut() async {
    try {
      await _auth.signOut();
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code, message: e.message);
    }
  }

  @override
  User? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _userFromFirebase(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message,
      );
    }
  }
}
