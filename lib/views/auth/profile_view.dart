import 'package:flutter/material.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';
import 'package:glico_stores/models/user.dart';
import 'package:glico_stores/services/auth_service.dart';
import 'package:glico_stores/services/database_service.dart';
import 'package:glico_stores/utils/utilities.dart';
import 'package:glico_stores/widgets/empty_state_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error, could not sign out"),
        ),
      );
    }
  }
    final DatabaseService db = locator<DatabaseService>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final User? currentUser = Provider.of<AuthBase>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          margin: const EdgeInsets.only(top: 48.0),
          child: FutureBuilder<User>(
              future: currentUser != null ? db.getUser(currentUser.uid) : null,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final user = snapshot.data;
                  final String initials =
                      Utilities.getNameInitials(firstname: user!.firstName!);

                  return ListView(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Color(
                          int.parse(
                            user.color!.replaceRange(0, 3, "0x73"),
                          ),
                        ),
                        child: Text(
                          initials,
                          style: theme.textTheme.headlineLarge!.copyWith(
                            color: Color(
                              int.parse(user.color!),
                            ),
                          ),
                        ),
                      ),
                      Spacing.verticalSpace48,
                      Text(
                        "${user.firstName} ${user.lastName}",
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      Spacing.verticalSpace16,
                      Text(
                        "${user.email}",
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      Spacing.verticalSpace48,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                "${user.addedBusinesses!.length}",
                                style: theme.textTheme.bodyLarge,
                              ),
                              Text(
                                "registered",
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "4",
                                style: theme.textTheme.bodyLarge,
                              ),
                              Text(
                                "registered",
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "4",
                                style: theme.textTheme.bodyLarge,
                              ),
                              Text(
                                "registered",
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(
                        height: 48,
                      ),
                      TextButton.icon(
                        onPressed: () => signOut(),
                        icon: Icon(
                          LucideIcons.logOut,
                          color: theme.colorScheme.error,
                        ),
                        label: Text(
                          "Sign out",
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      )
                    ],
                  );
                } else if (snapshot.hasError) {
                  const EmptyStateLayout(
                    nullIcon: LucideIcons.alertTriangle,
                    nullLabel: "Error",
                    nullSubLabel: "Could not get user details.",
                  );
                }
                return const CircularProgressIndicator.adaptive();
              }),
        ),
      ),
    );
  }
}
