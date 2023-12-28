import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.uid, this.radius = 40, this.onTap});

  final String uid;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UserData(
      uid: uid,
      field: Def.photoUrl,
      builder: (url) {
        if (url == null) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.person, size: 22, color: Colors.grey.shade700),
          );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: CachedNetworkImage(imageUrl: url),
          );
        }
      },
    );
  }
}
