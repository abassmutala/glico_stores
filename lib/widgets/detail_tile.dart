import 'package:flutter/material.dart';

class DetailTile extends StatelessWidget {
  const DetailTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final GestureTapCallback? onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: theme.textTheme.titleLarge,
      ),
      trailing: Icon(
        trailing,
        color: theme.colorScheme.secondary,
      ),
      onTap: onTap,
    );
  }
}
