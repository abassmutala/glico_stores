import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/constants/route_names.dart';
import '/constants/ui_constants.dart';
import '/locator.dart';
import '/models/store.dart';
import '/services/database_service.dart';
import '/services/navigation_service.dart';
import '/utils/utilities.dart';
import '/widgets/api_list_builder.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StoresList extends StatefulWidget {
  const StoresList({super.key});

  @override
  State<StoresList> createState() => _StoresListState();
}

class _StoresListState extends State<StoresList> {
  final DatabaseService db = locator<DatabaseService>();
  final NavigationService navService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<Store>?>(
        stream: db.getStoresStream(),
        builder: (context, snapshot) {
          return Stack(
            children: [
              Image.asset(
                "images/ericsson-mobility-report-novembe.png",
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
                      sliver(innerBoxIsScrolled, snapshot, theme),
                    ];
                  },
                  body: pageBody(snapshot, theme),
                ),
                floatingActionButton: fAB(theme),
              ),
            ],
          );
        });
  }

  Widget pageBody(AsyncSnapshot<List<Store>?> snapshot, ThemeData theme) {
    return Container(
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
        child: storesList(snapshot, theme),
      ),
    );
  }

  Widget storesList(AsyncSnapshot<List<Store>?> snapshot, ThemeData theme) {
    return SingleChildScrollView(
      child: APIListBuilder(
        physics: const NeverScrollableScrollPhysics(),
        snapshot: snapshot,
        separatorWidget: const SizedBox(
          height: 12.0,
        ),
        itemBuilder: (context, store) {
          final initials = Utilities.getInitials(store.name!);
          return Hero(
            tag: store.uid,
            child: Material(
              color: Colors.transparent,
              child: storeTile(theme, initials, store),
            ),
          );
        },
        nullIcon: LucideIcons.info,
        nullLabel: "Zzz",
        nullSubLabel: "No stores registered",
        errorSubtitle: "An error occured.",
      ),
    );
  }

  Widget fAB(ThemeData theme) {
    return FloatingActionButton(
      backgroundColor: theme.colorScheme.primary,
      onPressed: () => navService.navigateTo(addStoreRoute),
      child: const Icon(LucideIcons.plus),
    );
  }

  Widget sliver(bool innerBoxIsScrolled, AsyncSnapshot<List<Store>?> snapshot,
      ThemeData theme) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: kToolbarHeight * 4,
      pinned: true,
      stretch: true,
      elevation: 0.0,
      stretchTriggerOffset: 100,
      title: Visibility(
        visible: innerBoxIsScrolled,
        child: Text(
          "${snapshot.data?.length} registered stores",
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => navService.navigateTo(profileViewRoute),
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
                "images/ericsson-mobility-report-novembe.png",
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              Container(
                color: modalBg,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${snapshot.data?.length} registered stores",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.background,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget storeTile(ThemeData theme, String initials, Store store) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60.0),
      ),
      tileColor: const Color.fromRGBO(241, 241, 241, 1),
      leading: CircleAvatar(
        radius: 24,
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
        store.name!,
        style: theme.textTheme.titleLarge!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "${Utilities.convertStoreCategoryToText(store.category!)} ● ${store.address!}",
      ),
      onTap: () =>
          navService.navigateTo(storeDetailsRoute, arguments: store.uid),
    );
  }
}
