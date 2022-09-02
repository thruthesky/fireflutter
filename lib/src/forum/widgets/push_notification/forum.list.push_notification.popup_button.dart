import 'package:flutter/material.dart';

typedef OnSelectedFunction(dynamic selected);

class ForumListPushNotificationPopUpButton extends StatelessWidget {
  final OnSelectedFunction onSelected;
  final List<PopupMenuItem> items;
  final Widget icon;

  ForumListPushNotificationPopUpButton({
    Key? key,
    required this.items,
    required this.onSelected,
    this.icon = const Icon(Icons.more_vert),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<dynamic>(
      padding: EdgeInsets.all(0),
      itemBuilder: (context) => items,
      icon: icon,
      // offset: Offset(1.0, 5.0),
      offset: Offset.fromDirection(2, 46),
      onSelected: onSelected,
    );
  }
}
