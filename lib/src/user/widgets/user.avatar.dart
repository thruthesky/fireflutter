import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// 사용자 사진 표시
///
/// 사용자 사진 'users/<uid>/photoUrl' 값을 실시간으로 listen 해서 표시한다.
/// 이 때, 화면이 깜빡이지 않도록 캐시를 한다.
class UserAvatar extends StatefulWidget {
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
  State<UserAvatar> createState() => _UserAvatarState();

  /// 사용자 사진을 한번만 표시한다.
  ///
  /// DB 에 업데이트 되어도, 리빌드 하지 않는다.
  static once({
    required String uid,
    double size = 48,
    double radius = 20,
    VoidCallback? onTap,
  }) {
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
}

class _UserAvatarState extends State<UserAvatar> {
  // cache
  String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return UserDoc.sync(
      uid: widget.uid,
      field: Field.photoUrl,
      builder: (url) {
        photoUrl = url;
        return _avatar(url);
      },
      onLoading: _avatar(photoUrl),
    );
  }

  _avatar(String? url) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Avatar(
        photoUrl: (url == null || url == "") ? anonymousUrl : url,
        size: widget.size,
        radius: widget.radius,
      ),
    );
  }
}
