import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({
    super.key,
    // this.controller,
    required this.onPressed,
    required this.context,
    required this.icon,
  });
  final Function() onPressed;
  // final ChatRoomListViewController? controller;
  final BuildContext context;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Theme.of(context).canvasColor,
      onPressed: onPressed,
      elevation: 0,
      child: FaIcon(
        icon,
        size: sizeMd,
      ),
    );
  }
}
