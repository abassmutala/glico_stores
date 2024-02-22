import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/widgets/empty_state_layout.dart';
import 'package:lucide_icons/lucide_icons.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class APIListBuilder<T> extends StatelessWidget {
  const APIListBuilder({
    super.key,
    required this.snapshot,
    required this.itemBuilder,
    this.nullIcon,
    this.errorIcon = LucideIcons.alertTriangle,
    this.nullLabel,
    this.errorTitle,
    this.nullSubLabel,
    this.errorSubtitle,
    this.referralButtonTitle,
    this.referralAction,
    this.separatorWidget = const SizedBox(
      height: 4.0,
    ),
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.physics,
  });
  final AsyncSnapshot<List<T>?> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;
  final IconData? nullIcon;
  final IconData errorIcon;
  final String? nullLabel;
  final String? errorTitle;
  final String? nullSubLabel;
  final String? errorSubtitle;
  final String? referralButtonTitle;
  final GestureTapCallback? referralAction;
  final Widget separatorWidget;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<T>? items = snapshot.data;
      if (items!.isNotEmpty) {
        return _buildList(items);
      } else {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: EmptyStateLayout(
            nullIcon: nullIcon,
            nullLabel: nullLabel,
            nullSubLabel: nullSubLabel,
            referralAction: referralAction,
            referralButtonLabel: referralButtonTitle,
          ),
        );
      }
    } else if (snapshot.hasError) {
      debugPrint(snapshot.error.toString());
      debugPrint(snapshot.error.toString());
      return EmptyStateLayout(
        nullIcon: errorIcon,
        nullLabel: errorTitle,
        nullSubLabel: errorSubtitle,
      );
    }
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  Widget _buildList(List<T> items) {
    return ListView.separated(
      key: PageStorageKey<String>(items.toString()),
      physics: physics,
      padding: padding ?? Insets.standardPadding,
      scrollDirection: scrollDirection,
      shrinkWrap: true,
      itemBuilder: (context, index) => itemBuilder(context, items[index]),
      separatorBuilder: (context, index) => separatorWidget,
      itemCount: items.length,
    );
  }
}




              

              // if (snapshot.connectionState == ConnectionState.done) {
              //   Map<String, dynamic> data =
              //       snapshot.data!.data() as Map<String, dynamic>;
              //   final _host = CarHost.fromMap(data);
              //   return ListTile();
              // }

              // return const CircularProgressIndicator.adaptive();