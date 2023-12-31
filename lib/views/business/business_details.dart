import 'package:flutter/material.dart';
import 'package:glico_stores/constants/app_colors.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';

import 'package:glico_stores/models/business.dart';
import 'package:glico_stores/services/database_service.dart';
import 'package:glico_stores/services/navigation_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:glico_stores/utils/utilities.dart';
import 'package:glico_stores/widgets/detail_tile.dart';
import 'package:glico_stores/widgets/details_skeleton.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BusinessDetails extends StatefulWidget {
  const BusinessDetails(
    this.uid, {
    super.key,
  });

  final String uid;

  @override
  State<BusinessDetails> createState() => _BusinessDetailsState();
}

class _BusinessDetailsState extends State<BusinessDetails> {
  final DatabaseService db = locator<DatabaseService>();
  final NavigationService navService = locator<NavigationService>();
  final PageController controller = PageController();

  Future<void> deleteBusiness(String uid, String name) async {
    try {
      await db.deleteBusiness(uid).then(
            (value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text("$name deleted successfully"),
              ),
            ),
          );
      navService.pop();
      navService.navigateToReplacement(businessesListRoute);
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
    return FutureBuilder<Business>(
        future: db.getBusiness(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final Business business = snapshot.data!;
            return Hero(
              tag: widget.uid,
              child: Stack(
                children: [
                  business.photos!.isEmpty
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
                          sliverAppBar(theme, business, context),
                        ];
                      },
                      body: body(business, theme),
                    ),
                  ),
                ],
              ),
            );
          }
          return const DetailsSkeleton();
        });
  }

  Widget body(Business business, ThemeData theme) {
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
              title: "${business.owner}",
            ),
            divider(theme),
            DetailTile(
              icon: LucideIcons.mapPin,
              title: business.address!,
            ),
            divider(theme),
            phoneNumbersWidget(business.phone, theme),
            DetailTile(
              icon: LucideIcons.package,
              title: "To insure ${business.insuranceType!}",
            ),
            divider(theme),
            DetailTile(
              icon: LucideIcons.wallet,
              title:
                  "Assets estimated at a value of GH¢${business.estimatedAssetValue!}",
            ),
            divider(theme),
            DetailTile(
              icon: LucideIcons.coins,
              title: "To pay a premium of GH¢${business.premium!}",
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar sliverAppBar(
      ThemeData theme, Business business, BuildContext context) {
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
              editBusinessDetailsRoute,
              arguments: business.uid,
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
                return deleteDialog(business, theme, context);
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
      flexibleSpace: photosCarousel(business, theme),
    );
  }

  Widget photosCarousel(Business business, ThemeData theme) {
    return FlexibleSpaceBar(
      background: business.photos!.isNotEmpty
          ? PageView.builder(
              itemCount: business.photos!.length,
              controller: controller,
              itemBuilder: (context, index) => Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CachedNetworkImage(
                    progressIndicatorBuilder: (context, url, progress) =>
                        const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                    imageUrl: business.photos![index],
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
                            "${business.photos!.indexOf(business.photos![index]) + 1}",
                        style: theme.textTheme.titleSmall!
                            .copyWith(color: theme.colorScheme.secondary),
                        children: [
                          TextSpan(
                            text: "/${business.photos!.length}",
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
                  Utilities.getInitials(business.name!),
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
            business.name!,
            style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
          ),
          Text(
            "Business ID: ${business.uniqueCode!}",
            style: theme.textTheme.labelSmall!
                .copyWith(color: Colors.white, letterSpacing: 0),
          ),
        ],
      ),
      titlePadding: const EdgeInsetsDirectional.only(start: 72, bottom: 16),
    );
  }

  AlertDialog deleteDialog(
      Business business, ThemeData theme, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: const Text("Delete"),
      content: Text.rich(
        TextSpan(text: "Are you sure you want to delete ", children: [
          TextSpan(
            text: "${business.name}",
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
          onPressed: () => deleteBusiness(
            business.uid,
            business.name!,
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
                        //     context, business.phone!),
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
