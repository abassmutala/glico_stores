import 'package:flutter/material.dart';
import 'package:trilo/views/auth/profile.dart';
import 'package:trilo/views/auth/sign_up.dart';
import '/constants/route_names.dart';
import '/views/store/add_store.dart';
import '/views/store/store_details.dart';
import '/views/store/stores_list.dart';
import '/views/store/edit_details.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case storesListRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const StoresList(),
      );
    case addStoreRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const AddStore(),
      );
    case storeDetailsRoute:
      final String uid = settings.arguments as String;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: StoreDetails(uid),
      );
    case editStoreDetailsRoute:
      final String args = settings.arguments as String;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: EditDetails(
          uid: args,
        ),
      );
    case signUpViewRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const SignUp(),
      );
    case profileViewRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const ProfileView(),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text(''),
          ),
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
  }
}

PageRoute _getPageRoute(
    {required String routeName, required Widget viewToShow}) {
  return MaterialPageRoute(
    settings: RouteSettings(
      name: routeName,
    ),
    builder: (_) => viewToShow,
  );
}

// Route<dynamic> _errorRoute() {
//   return MaterialPageRoute(
//     builder: (_) => Scaffold(
//       appBar: AppBar(
//         title: const Text(''),
//       ),
//       body: const Center(
//         child: Text('ERROR'),
//       ),
//     ),
//   );
// }
