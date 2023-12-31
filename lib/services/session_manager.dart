import 'package:firebase_auth/firebase_auth.dart';
import 'package:glico_stores/services/database_service.dart';

class SessionManager {
  static const int sessionDurationInHours = 72;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> checkAndLogoutIfExpired() async {
    final User? user = _auth.currentUser;
    
    if (user != null) {
      final DateTime? lastActivityTimestamp = user.metadata.lastSignInTime;
      final DateTime currentTimestamp = DateTime.now();
      
      final Duration difference = currentTimestamp.difference(lastActivityTimestamp!);
      if (difference.inHours >= sessionDurationInHours) {
        await DatabaseService().deleteUser(user.uid);
        await _auth.currentUser!.delete();
      }
    }
  }

  void updateLastActivityTimestamp() {
    final User? user = _auth.currentUser;
    
    if (user != null) {
      // Update the user's last activity timestamp
      // This should be called whenever the user interacts with the app
    }
  }
}
