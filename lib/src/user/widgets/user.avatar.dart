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
    return UserDoc(
      uid: uid,
      field: Field.photoUrl,
      builder: (url) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Avatar(
          photoUrl: (url == null || url == "") ? anonymousUrl : url,
          size: size,
          radius: radius,
        ),
      ),
    );
  }

  static sync({
    required String uid,
    double size = 48,
    double radius = 20,
    VoidCallback? onTap,
  }) {
    return UserDoc.sync(
      uid: uid,
      field: Field.photoUrl,
      builder: (url) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Avatar(
          photoUrl: (url == null || url == "") ? anonymousUrl : url,
          size: size,
          radius: radius,
        ),
      ),
    );
  }
}
