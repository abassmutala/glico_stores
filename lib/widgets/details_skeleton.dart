import 'package:flutter/material.dart';
import 'package:glico_stores/constants/ui_constants.dart';

class DetailsSkeleton extends StatefulWidget {
  const DetailsSkeleton({super.key});

  @override
  State<DetailsSkeleton> createState() => _DetailsSkeletonState();
}

class _DetailsSkeletonState extends State<DetailsSkeleton> {
  final bool _isInitialValue = true;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        AnimatedContainer(
          // transform: ,
          duration: const Duration(seconds: 1), height: kToolbarHeight * 7,
          color: theme.colorScheme.onBackground
              .withOpacity(_isInitialValue ? 0.1 : 0.2),
        ),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: ScreenSize.width >= 600 ? 80 : 0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 4,
            itemBuilder: (context, index) => ListTile(
              leading: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Row(
                children: [
                  AnimatedContainer(
                    constraints: const BoxConstraints(maxWidth: 350),
                    height: 24,
                    width: ScreenSize.width / index + 1,
                    duration: const Duration(milliseconds: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.onBackground.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
