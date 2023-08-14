import 'package:flutter/material.dart';
import 'package:glico_stores/constants/ui_constants.dart';

class EmptyStateLayout extends StatelessWidget {
  final IconData? nullIcon;
  final String? nullLabel;
  final String? nullSubLabel;
  final GestureTapCallback? referralAction;
  final String? referralButtonLabel;

  const EmptyStateLayout({
    Key? key,
    required this.nullIcon,
    this.nullLabel,
    this.nullSubLabel,
    this.referralAction,
    this.referralButtonLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacing.verticalSpace24,
          Icon(
            nullIcon,
            size: IconSizes.largest,
            color: theme.colorScheme.outline,
          ),
          Spacing.verticalSpace12,
          if (nullLabel != null)
            Padding(
              padding: Insets.verticalPadding4,
              child: Text(
                nullLabel!,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
          if (nullSubLabel != null)
            Padding(
              padding: Insets.standardPadding,
              child: Text(
                nullSubLabel!,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          if (referralAction != null)
            Padding(
              padding: Insets.standardPadding
                  .add(const EdgeInsets.symmetric(horizontal: 48.0)),
              child: SizedBox(
                child: OutlinedButton(
                  onPressed: referralAction!,
                  child: Text(referralButtonLabel!),
                ),
              ),
            )
        ],
      ),
    );
  }
}
