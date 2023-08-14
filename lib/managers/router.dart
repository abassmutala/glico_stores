import 'package:flutter/material.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/views/auth/forgot_password.dart';
import 'package:glico_stores/views/auth/profile_view.dart';
import 'package:glico_stores/views/auth/sign_in.dart';
import 'package:glico_stores/views/auth/sign_up.dart';
import 'package:glico_stores/views/business/add_business.dart';
import 'package:glico_stores/views/business/business_details.dart';
import 'package:glico_stores/views/business/businesses_list.dart';
import 'package:glico_stores/views/business/edit_details.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case businessesListRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const BusinessesList(),
      );
    case addBusinessRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const AddBusiness(),
      );
    case businessDetailsRoute:
      final String uid = settings.arguments as String;
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: BusinessDetails(uid),
      );
    case editBusinessDetailsRoute:
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
    case signInViewRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const SignIn(),
      );
    case forgotPasswordRoute:
      return _getPageRoute(
        routeName: settings.name!,
        viewToShow: const ForgotPassword(),
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
