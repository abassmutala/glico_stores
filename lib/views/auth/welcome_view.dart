import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';
import 'package:glico_stores/services/navigation_service.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NavigationService navService = locator<NavigationService>();

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
                SizedBox(
                  width: 350,
                  child: SvgPicture.asset(
                    "images/glico_general_logo.svg",
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 54,
                  width: 192,
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
                GestureDetector(
                  child: const Text(
                    "Already have an account? Sign in",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => navService.navigateTo(signInViewRoute),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
