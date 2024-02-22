import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trilo/services/auth_service.dart';
import 'package:trilo/views/auth/landing_page.dart';
import 'constants/app_themes.dart';
import 'constants/ui_constants.dart';
import 'locator.dart';
import 'managers/router.dart';
import 'services/navigation_service.dart';
import 'views/store/stores_list.dart';

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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: generateRoute,
        title: 'Trilo',
        navigatorKey: locator<NavigationService>().navigationKey,
        theme: glicoLightTheme,
        home: LandingPage(),
      ),
    );
  }
}
