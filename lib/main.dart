import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:glico_stores/constants/app_themes.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';
import 'package:glico_stores/managers/router.dart';
import 'package:glico_stores/services/auth_service.dart';
import 'package:glico_stores/services/navigation_service.dart';
import 'package:glico_stores/views/auth/landing_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MultiProvider(
        providers: [
          Provider<AuthBase>(
            create: (context) => AuthService(),
          )
        ],
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateRoute: generateRoute,
            title: 'Glico Stores',
            navigatorKey: locator<NavigationService>().navigationKey,
            theme: glicoLightTheme,
            home: LandingPage(),
          );
        });
  }
}
