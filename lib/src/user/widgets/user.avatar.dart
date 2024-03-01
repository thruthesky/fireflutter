import 'package:fireflutter/fireflutter.dart';
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
    this.sync = false,
  });

  final String uid;
  final double size;
  final double radius;
  final VoidCallback? onTap;
  final String? initialData;
  final bool sync;

  @override
  Widget build(BuildContext context) {
    if (sync) {
      return UserDoc.fieldSync(
        uid: uid,
        initialData: initialData,
        field: Field.photoUrl,
        builder: builder,
      );
    } else {
      return UserDoc.field(
        uid: uid,
        field: Field.photoUrl,
        builder: builder,
      );
    }
  }

  const UserAvatar.sync({
    Key? key,
    required String uid,
    double size = 48,
    double radius = 20,
    VoidCallback? onTap,
    String? initialData,
  }) : this(
          key: key,
          uid: uid,
          size: size,
          radius: radius,
          onTap: onTap,
          initialData: initialData,
          sync: true,
        );

  Widget builder(dynamic url) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Avatar(
          photoUrl: (url == null || url == "") ? anonymousUrl : url,
          size: size,
          radius: radius,
        ),
      );
}
