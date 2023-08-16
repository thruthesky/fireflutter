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
      return defaultIcon ?? const Icon(Icons.person);
    }
    return Avatar(url: user.photoUrl, size: size);
  }
}
