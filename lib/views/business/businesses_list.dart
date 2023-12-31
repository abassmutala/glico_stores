import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glico_stores/constants/app_colors.dart';
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
          return Stack(
            children: [
              Image.asset(
                "images/rectangle.png",
                fit: BoxFit.cover,
              ),
              const ModalBarrier(
                color: modalBg,
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: NestedScrollView(
                  physics: const BouncingScrollPhysics(),
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        expandedHeight: kToolbarHeight * 4,
                        pinned: false,
                        stretch: true,
                        elevation: 0.0,
                        stretchTriggerOffset: 100,
                        actions: [
                          IconButton(
                            onPressed: () =>
                                navService.navigateTo(profileViewRoute),
                            icon: Icon(
                              LucideIcons.userCircle2,
                              size: 32,
                              color: theme.colorScheme.background,
                            ),
                          ),
                          // Spacing.horizontalSpace16
                        ],
                        flexibleSpace: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: ScreenSize.width >= 600
                                ? const Radius.circular(60)
                                : const Radius.circular(25),
                          ),
                          child: FlexibleSpaceBar(
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  "images/rectangle.png",
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                                Container(
                                  color: modalBg,
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 320,
                                      child: SvgPicture.asset(
                                          "images/glico_general_logo.svg"),
                                    ),
                                    Text(
                                      "${snapshot.data?.length} registered businesses",
                                      style: TextStyle(
                                          color: theme.colorScheme.background),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: Container(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenSize.width >= 600 ? 48 : 0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: ScreenSize.width >= 600
                              ? const Radius.circular(60)
                              : const Radius.circular(25),
                        ),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Spacing.verticalSpace8,
                            ElevatedButton(
                              onPressed: () =>
                                  navService.navigateTo(addBusinessRoute),
                              child: const Text(
                                "Add business",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Spacing.verticalSpace12,
                            APIListBuilder(
                              physics: const NeverScrollableScrollPhysics(),
                              snapshot: snapshot,
                              separatorWidget: const SizedBox(
                                height: 12.0,
                              ),
                              itemBuilder: (context, business) {
                                final initials =
                                    Utilities.getInitials(business.name!);
                                return Hero(
                                  tag: business.uid,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      dense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(60.0),
                                      ),
                                      tileColor:
                                          const Color.fromRGBO(241, 241, 241, 1),
                                      // isThreeLine: true,
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            theme.colorScheme.primary,
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
                                        style:
                                            theme.textTheme.titleLarge!.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            Utilities
                                                .convertbusinessCategoryToText(
                                                    business.category!),
                                          ),
                                          Text(business.address!),
                                        ],
                                      ),
                                      onTap: () => navService.navigateTo(
                                          businessDetailsRoute,
                                          arguments: business.uid),
                                    ),
                                  ),
                                );
                              },
                              nullIcon: LucideIcons.info,
                              nullLabel: "Zzz",
                              nullSubLabel: "No businesses registered",
                              errorSubtitle: "An error occured.",
                            ),
                            Spacing.verticalSpace24,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
