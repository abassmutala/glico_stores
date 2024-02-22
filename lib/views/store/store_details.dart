import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/constants/route_names.dart';
import '/constants/ui_constants.dart';
import '/locator.dart';
import '/models/store.dart';
import '/services/database_service.dart';
import '/services/navigation_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/utils/utilities.dart';
import '/widgets/detail_tile.dart';
import '/widgets/details_skeleton.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StoreDetails extends StatefulWidget {
  const StoreDetails(
    this.uid, {
    super.key,
  });

  final String uid;

  @override
  State<StoreDetails> createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<StoreDetails> {
  final DatabaseService db = locator<DatabaseService>();
  final NavigationService navService = locator<NavigationService>();
  final PageController controller = PageController();

  Future<void> deleteStore(String uid, String name) async {
    try {
      await db.deleteStore(uid).then(
            (value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text("$name deleted successfully"),
              ),
            ),
          );
      navService.pop();
      navService.navigateToReplacement(storesListRoute);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error, could not delete $name"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FutureBuilder<Store>(
        future: db.getStore(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final Store store = snapshot.data!;
            return Hero(
              tag: widget.uid,
              child: Stack(
                children: [
                  store.photos!.isEmpty
                      ? Container(
                          color: theme.colorScheme.secondary,
                        )
                      : Container(),
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    body: NestedScrollView(
                      physics: const BouncingScrollPhysics(),
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          sliverAppBar(theme, store, context),
                        ];
                      },
                      body: body(store, theme),
                    ),
                  ),
                ],
              ),
            );
          }
          return const DetailsSkeleton();
        });
  }

  Widget body(Store store, ThemeData theme) {
    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: ScreenSize.width >= 600
                ? const Radius.circular(60.0)
                : const Radius.circular(16.0),
          ),
          color: Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenSize.width >= 600 ? 80 : 0,
          ),
          children: [
            Spacing.verticalSpace16,
            DetailTile(
              icon: LucideIcons.user2,
              title: "${store.owner}",
            ),
            divider(theme),
            DetailTile(
              icon: LucideIcons.mapPin,
              title: store.address!,
            ),
            divider(theme),
            DetailTile(
              icon: LucideIcons.messageSquare,
              title: store.comment!,
            ),
            divider(theme),
            phoneNumbersWidget(store.phone, theme),
          ],
        ),
      ),
    );
  }

  SliverAppBar sliverAppBar(
      ThemeData theme, Store store, BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        onPressed: () => navService.pop(),
        icon: const Icon(
          LucideIcons.chevronLeft,
          color: Colors.white,
          size: 32,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            navService.navigateTo(
              editStoreDetailsRoute,
              arguments: store.uid,
            );
          },
          icon: const Icon(
            LucideIcons.edit2,
            color: Colors.white,
          ),
          tooltip: "Edit",
        ),
        IconButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return deleteDialog(store, theme, context);
              }),
          icon: const Icon(
            LucideIcons.trash,
            color: Colors.white,
          ),
          tooltip: "Delete",
        )
      ],
      expandedHeight: kToolbarHeight * 6,
      pinned: true,
      stretch: true,
      elevation: 0.0,
      stretchTriggerOffset: 100,
      flexibleSpace: photosCarousel(store, theme),
    );
  }

  Widget photosCarousel(Store store, ThemeData theme) {
    return FlexibleSpaceBar(
      background: store.photos!.isNotEmpty
          ? PageView.builder(
              itemCount: store.photos!.length,
              controller: controller,
              itemBuilder: (context, index) => Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CachedNetworkImage(
                    progressIndicatorBuilder: (context, url, progress) =>
                        const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                    imageUrl: store.photos![index],
                    errorWidget: (context, url, error) => const Icon(
                      LucideIcons.imageOff,
                      size: IconSizes.largest,
                    ),
                    fit: BoxFit.cover,
                    width: ScreenSize.width,
                  ),
                  Container(
                    color: Colors.black54,
                    // onDismiss: () {},
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: theme.canvasColor.withOpacity(0.5),
                    ),
                    padding: Insets.buttonPadding,
                    margin: const EdgeInsetsDirectional.only(
                      start: 72,
                      end: 24,
                      bottom: 16,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text:
                            "${store.photos!.indexOf(store.photos![index]) + 1}",
                        style: theme.textTheme.titleSmall!
                            .copyWith(color: theme.colorScheme.secondary),
                        children: [
                          TextSpan(
                            text: "/${store.photos!.length}",
                            style: theme.textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              color: theme.colorScheme.secondary,
              child: Center(
                child: Text(
                  Utilities.getInitials(store.name!),
                  style: theme.textTheme.displayMedium!.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
      stretchModes: const [
        StretchMode.zoomBackground,
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            store.name!,
            style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
          ),
          Text(
            "Store ID: ${store.uniqueCode!} ● ${Utilities.convertStoreCategoryToText(store.category!)}",
            style: theme.textTheme.labelSmall!
                .copyWith(color: Colors.white, letterSpacing: 0),
          ),
        ],
      ),
      titlePadding: const EdgeInsetsDirectional.only(start: 72, bottom: 16),
    );
  }

  AlertDialog deleteDialog(Store store, ThemeData theme, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: const Text("Delete"),
      content: Text.rich(
        TextSpan(text: "Are you sure you want to delete ", children: [
          TextSpan(
            text: "${store.name}",
            style: TextStyle(
              color: theme.colorScheme.primary,
            ),
          ),
          const TextSpan(
            text: "?",
          )
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => deleteStore(
            store.uid,
            store.name!,
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              theme.colorScheme.errorContainer,
            ),
          ),
          child: const Text("Delete"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  Widget divider(ThemeData theme) {
    return const Divider(
      color: borderColor,
    );
  }

  Widget phoneNumbersWidget(List? phoneNumbers, ThemeData theme) {
    return phoneNumbers!.isNotEmpty
        ? Column(
            children: phoneNumbers
                .map(
                  (e) => Column(
                    children: [
                      DetailTile(
                        icon: LucideIcons.phone,
                        title: e,
                        trailing: LucideIcons.arrowUpRight,
                        // onTap: () => _launcherService.makePhoneCall(
                        //     context, store.phone!),
                      ),
                      divider(theme),
                    ],
                  ),
                )
                .toList(),
          )
        : Container();
  }
}
