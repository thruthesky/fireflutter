import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategorySubscriptionIcon extends StatelessWidget {
  const CategorySubscriptionIcon({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        toggle(
          ref: ForumService.categoryPushNotificationPath(category),
        );
      },
      icon: Value(
        ref: ForumService.categoryPushNotificationPath(category),
        builder: (v) => v == true
            ? const Icon(Icons.notifications_rounded)
            : const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
