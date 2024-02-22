import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/route_names.dart';
import '../../constants/ui_constants.dart';
import '../../locator.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late bool isLoading;
  final AuthService _auth = locator<AuthService>();
  final NavigationService navService = locator<NavigationService>();

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  Future signIn(ThemeData theme) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _auth.signInWithToken("token");
      setState(() {
        isLoading = false;
      });
      navService.navigateToReplacement(storesListRoute);
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sign in failed"),
          content: Text("${e.message}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          "images/tanzania_woman.png",
          fit: BoxFit.cover,
        ),
        const ModalBarrier(
          color: Colors.black54,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            margin: const EdgeInsets.symmetric(vertical: 96.0),
            width: ScreenSize.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  height: 54,
                  width: ScreenSize.width,
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            theme.colorScheme.secondary)),
                    onPressed: () => navService.navigateTo(signUpViewRoute),
                    child: Text(
                      "Sign Up",
                      style: theme.textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Spacing.verticalSpace16,
                Container(
                  height: 54,
                  width: ScreenSize.width,
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            theme.colorScheme.secondary)),
                    onPressed: () async =>
                        !isLoading ? await signIn(theme) : null,
                    child: Text(
                      "Sign In",
                      style: theme.textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
