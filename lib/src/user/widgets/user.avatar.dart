import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// 사용자 사진 표시
///
/// [uid] 사용자 uid
///
/// [size] 크기
///
/// [radius] 둥근 모서리
///
/// [onTap] 클릭시 실행할 콜백 함수
///
/// [initialData] when [initialData] is provided, it will be use as the photo url
/// instead of showing the loader (or SizedBox.shrink).
///
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.uid,
    this.size = 48,
    this.radius = 20,
    this.onTap,
    this.initialData,
  });

  final String uid;
  final double size;
  final double radius;
  final VoidCallback? onTap;
  final String? initialData;

  @override
  Widget build(BuildContext context) {
    return UserDoc.sync(
      uid: uid,
      initialData: initialData,
      field: Field.photoUrl,
      builder: (url) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Avatar(
            photoUrl: (url == null || url == "") ? anonymousUrl : url,
            size: size,
            radius: radius,
          ),
        );
      },
    );
  }

  /// 사용자 사진을 한번만 표시한다.
  ///
  /// DB 에 업데이트 되어도, 리빌드 하지 않는다.
  static once({
    required String uid,
    double size = 48,
    double radius = 20,
    VoidCallback? onTap,
  }) {
    return UserDoc.field(
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
