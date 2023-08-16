import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 32, this.defaultIcon});

  final User user;
  final double size;
  final Widget? defaultIcon;

  @override
  Widget build(BuildContext context) {
    if (user.hasPhotoUrl == false) {
      return defaultIcon ??
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: size / 2,
            ),
          );
    }
    return Avatar(url: user.photoUrl, size: size);
  }
}
