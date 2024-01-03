import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// 사용자 사진 표시
///
/// 'users/uid/photoUrl' 값을 실시간으로 listen 해서 표시.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.uid,
    this.size = 48,
    this.radius = 20,
    this.onTap,
  });

  final String uid;
  final double size;
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

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: url == null
              ? AnonymousAvatar(
                  size: size,
                  radius: radius,
                )
              : Avatar(
                  photoUrl: url,
                  size: size,
                  radius: radius,
                ),
        );
      },
    );
  }
}
