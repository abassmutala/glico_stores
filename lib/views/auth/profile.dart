import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:trilo/constants/app_colors.dart';
import 'package:trilo/constants/route_names.dart';
import 'package:trilo/constants/ui_constants.dart';
import 'package:trilo/locator.dart';
import 'package:trilo/models/user.dart';
import 'package:trilo/services/auth_service.dart';
import 'package:trilo/services/database_service.dart';
import 'package:trilo/services/navigation_service.dart';
import 'package:trilo/utils/utilities.dart';
import 'package:trilo/widgets/empty_state_layout.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Future<void> signOut() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      await auth.signOut();
      navService.navigateToReplacement(welcomeViewRoute);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error, could not sign out"),
        ),
      );
    }
  }

  final DatabaseService db = locator<DatabaseService>();
  final NavigationService navService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final User? currentUser = Provider.of<AuthBase>(context).currentUser;

    return FutureBuilder<User>(
        future: currentUser != null ? db.getUser(currentUser.uid) : null,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data;
            final String initials =
                Utilities.getNameInitials(firstname: user!.firstName!);
            final Color userColor = Color(
              int.parse(
                user.color!,
              ),
            );
            return Stack(
              children: [
                Image.asset(
                  "images/ericsson-mobility-report-novembe.png",
                  fit: BoxFit.cover,
                ),
                const ModalBarrier(
                  color: Colors.black54,
                ),
                Positioned(
                  top: 24.0,
                  left: 16.0,
                  child: IconButton(
                    onPressed: () => navService.pop(),
                    icon: const Icon(
                      LucideIcons.chevronLeft,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: ScreenSize.height * 0.2,
                    ),
                    Container(
                      height: ScreenSize.height * 0.8,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: ScreenSize.width >= 600
                                ? const Radius.circular(60)
                                : const Radius.circular(25),
                          ),
                          color: Colors.white,
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenSize.width >= 600 ? 80 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 80),
                          child: Column(
                            children: [
                              Text(
                                "${user.firstName} ${user.lastName}",
                                style: theme.textTheme.headlineMedium!
                                    .copyWith(color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              Spacing.verticalSpace4,
                              Text(
                                "${user.email}",
                                style: theme.textTheme.headlineSmall!
                                    .copyWith(color: subtitleColor),
                                textAlign: TextAlign.center,
                              ),
                              Spacing.verticalSpace4,
                              Text(
                                "${user.uniqueCode}",
                                style: theme.textTheme.headlineSmall!
                                    .copyWith(color: subtitleColor),
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(),
                              signOutButton()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: ScreenSize.height * 0.129,
                  left: 0,
                  right: 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.white,
                        child: Text(
                          initials,
                          style: theme.textTheme.headlineLarge!.copyWith(
                              color: Color(
                                int.parse(user.color!),
                              ),
                              fontFamily: "Nunito"),
                        ),
                      ),
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: userColor.withOpacity(0.5),
                        child: Text(
                          initials,
                          style: theme.textTheme.headlineLarge!.copyWith(
                            color: Color(
                              int.parse(user.color!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            const EmptyStateLayout(
              nullIcon: LucideIcons.alertTriangle,
              nullLabel: "Error",
              nullSubLabel: "Could not get user details.",
            );
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        });
  }

  Row signOutButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 54,
          width: 192,
          child: ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(
                kGlicoError,
              ),
            ),
            onPressed: () async => await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      title: const Text("Sign out"),
                      content: const Text("Are you sure you want to sign out?"),
                      actions: [
                        TextButton(
                          onPressed: () => navService.pop(),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStatePropertyAll<Color?>(Theme.of(context).colorScheme.error),
                            // backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.error.withOpacity(0.5))
                          ),
                          onPressed: () async => await signOut(),
                          child: const Text("Sign out"),
                        ),
                      ],
                    )),
            child: const Text(
              "Sign out",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}