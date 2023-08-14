import 'package:flutter/material.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';
import 'package:glico_stores/models/business.dart';
import 'package:glico_stores/models/user.dart';
import 'package:glico_stores/services/auth_service.dart';
import 'package:glico_stores/services/database_service.dart';
import 'package:glico_stores/services/navigation_service.dart';
import 'package:glico_stores/utils/utilities.dart';
import 'package:glico_stores/widgets/api_list_builder.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class BusinessesList extends StatefulWidget {
  const BusinessesList({super.key});

  @override
  State<BusinessesList> createState() => _BusinessesListState();
}

class _BusinessesListState extends State<BusinessesList> {
  final DatabaseService db = locator<DatabaseService>();
  final NavigationService navService = locator<NavigationService>();

  // Future<List<Business>?> getBusinesses() async {
  //   final List<Business> list = await db.collectionFuture(
  //     path: APIPath.businesses(),
  //   ) as List<Business>;
  //   return list;
  // }

  Future<User> getCurrentUser(uid) async {
    return await db.getUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final User? currentUser = Provider.of<AuthBase>(context).currentUser;

    return StreamBuilder<List<Business>?>(
        stream: db.getBusinessesStream(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: kToolbarHeight * 2,
              // centerTitle: false,
              title: SizedBox(
                height: kToolbarHeight * 0.75,
                child: Image.asset(
                  "images/glicogeneral_logo.png",
                ),
              ),
              actions: [
                InkWell(
                  onTap: () => navService.navigateTo(profileViewRoute),
                  child: FutureBuilder<User>(
                      future: currentUser != null
                          ? db.getUser(currentUser.uid)
                          : null,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final user = snapshot.data;
                          final String initials = Utilities.getNameInitials(
                              firstname: user!.firstName!);
                          return CircleAvatar(
                            maxRadius: 28,
                            backgroundColor: Color(
                              int.parse(
                                user.color!.replaceRange(0, 3, "0x73"),
                              ),
                            ),
                            child: Text(
                              initials,
                              style: theme.textTheme.titleLarge,
                            ),
                          );
                        }
                        return const CircleAvatar(
                          maxRadius: 28,
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }),
                ),
                Spacing.horizontalSpace16
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kTextTabBarHeight / 2),
                child: Text(
                    "Displaying ${snapshot.data?.length} registered businesses"),
              ),
            ),
            body: APIListBuilder(
              snapshot: snapshot,
              itemBuilder: (context, business) {
                final initials = Utilities.getInitials(business.name!);
                return Hero(
                  tag: business.uid,
                  child: Card(
                    child: ClipRRect(
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // isThreeLine: true,
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          business.name!,
                          style: theme.textTheme.titleLarge!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(business.category!),
                            Text(business.address!),
                          ],
                        ),
                        onTap: () => navService.navigateTo(businessDetailsRoute,
                            arguments: business.uid),
                      ),
                    ),
                  ),
                );
              },
              nullIcon: LucideIcons.info,
              nullLabel: "Zzz",
              nullSubLabel: "No businesses registered",
              errorSubtitle: "An error occured.",
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              onPressed: () => navService.navigateTo(addBusinessRoute),
              tooltip: "Add business",
              icon: const Icon(LucideIcons.plus),
              label: const Text("Add business"),
              // label: const Text("Add staff"),
            ),
          );
        });
  }
}
