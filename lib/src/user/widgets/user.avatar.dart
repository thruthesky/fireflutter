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
/// instead of showing the loader (or SizedBox.shrink). And this reduce the flickering
/// dramatically.
///
/// [sync] 사용자 사진을 실시간으로 표시한다. 즉, 사용자 사진이 변경되면, 실시간으로 변경된 사진을 보여준다.
/// 참고로, 로그인 사용자 사진을 표시 할 대, sync 옵션을 쓰면, 깜빡임이 덜한데 왜 그런지 모르겠다. (2024.03.21)
///
/// 사용자 사진이 깜빡이는 경우, 캐시를 사용하면 화면 깜빡임이 줄어든다.
/// 단적인 예를 들면 채팅방에서, 메시지와 사진이 깜빡이는데, 이는 사진때문에 깜빡일 확률이 높다.
/// 특히 사진을 로드 할 때, 항상 로딩 중 위젯 표시가 되고, 사진이 표시된다.
/// 이를 방지하기 위해 캐시를 사용한다.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.uid,
    this.size = 48,
    this.radius = 20,
    this.onTap,
    this.initialData,
    this.cacheId,
    this.sync = false,
  });

  final String uid;
  final double size;
  final double radius;
  final VoidCallback? onTap;
  final String? initialData;
  final String? cacheId;
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
        cacheId: cacheId,
        initialData: initialData,
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
