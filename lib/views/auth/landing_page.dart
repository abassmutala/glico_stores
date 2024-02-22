import 'package:flutter/material.dart';
import 'package:trilo/locator.dart';
import 'package:trilo/services/auth_service.dart';
import 'package:trilo/views/auth/welcome_view.dart';
import 'package:trilo/views/store/stores_list.dart';

import '../../models/user.dart';

class LandingPage extends StatelessWidget {
  LandingPage({super.key});

//   @override
//   _LandingPageState createState() => _LandingPageState();
// }

// class _LandingPageState extends State<LandingPage> {
  // late FirebaseMessaging fbm;

  // @override
  // void initState() {
  //   super.initState();
  //   fbm = FirebaseMessaging.instance;
  //   fbm.requestPermission();
  //   fbm.getToken().then((value) => print(value));
  //   FirebaseMessaging.onMessage.listen((RemoteMessage event) {
  //       print("message recieved");
  //       print(event.notification!.body);
  //   });
  //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //   });
  // }
  final AuthService _authService = locator<AuthService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          User? user = snapshot.data;
          if (user == null) {
            return const Welcome();
          }
          return const StoresList();
        });
  }
}
