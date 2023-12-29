import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// 사용자 사진 표시
///
/// 'users/uid/photoUrl' 값을 실시간으로 listen 해서 표시.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.uid, this.radius = 40, this.onTap});

  final String uid;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserModel.fromUid(uid).ref.child(Def.photoUrl).onValue,
      builder: (_, event) {
        final url = event.hasData && event.data!.snapshot.exists
            ? event.data!.snapshot.value as String
            : null;

        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: url != null
              ? CachedNetworkImageProvider(
                  url,
                )
              : null,
          child: url == null
              ? Icon(Icons.person, size: radius * 1.6, color: Colors.grey.shade700)
              : null,
        );
      },
    );
  }
}
