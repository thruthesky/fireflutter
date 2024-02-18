import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// 사용자 사진 URL 을 UID 별로 캐시
final Map<String, Map<String, String?>> globalUserAvatarCache = {};
addGlobalUserAvatarCache(String? id, String uid, String? url) {
  if (id == null) return;
  if (globalUserAvatarCache[id] == null) {
    globalUserAvatarCache[id] = {};
  }
  globalUserAvatarCache[id]![uid] = url;
}

String? getGlobalUserAvatarCache(String? id, String uid) {
  if (id == null) return null;
  if (globalUserAvatarCache[id] == null) {
    globalUserAvatarCache[id] = {};
  }
  return globalUserAvatarCache[id]![uid];
}

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
/// [cacheId] 캐시 ID.
/// 사용자 사진을 화면에 보여 줄 때, 가장 큰 문제는 깜빡거림이다.
/// 이 위젯은 사용자 사진 노드 'users/<uid>/photoUrl' 값을 실시간으로 listen 해서 화면에 표시한다.
/// 만약, 사용자가 사진을 수정하면, DB 의 URL값이 변경 되는데, 이 때에는 간단힌 멤버 변수 하나로 해결 할 수 있다.
/// 하지만, 상단(부모위젯)에서 rebuid 하면, 현재 위젯을 다시 그리게되며 이때, 멤버 변수도 초기화 되어, 임시 이미지를 보여주고
/// DB 로 부터 URL 값을 다시 가져와 화면에 보여주므로, 깜빡이게 된다. 특히, 채팅방 같은 곳에서 채팅 메세지가 전송될 때 마다
/// 본 위젯을 다시 그리고, DB 로 부터 URL 을 다시 가져와야 해서, Avatar 가 깜빡이게 되는데, [cacheId] 로 각 사용자
/// 별 URL 을 캐시 해 놓고, DB 에서 가져오기 전에, onLoading 에서 캐시된 URL 을 사용해서, 깜빡이지 않게 한다.
/// [cacheId] 는 문자열이며, 깜빡임이 자주 발생하는 곳에서 "cacheId: chatRoom" 과 같이 하면, 그리고 필요하면 key 를
/// 사용하면, 깜빡임이 현저하게 줄어든다.
class UserAvatar extends StatefulWidget {
  const UserAvatar({
    super.key,
    required this.uid,
    this.size = 48,
    this.radius = 20,
    this.onTap,
    this.cacheId,
  });

  final String uid;
  final double size;
  final double radius;
  final VoidCallback? onTap;
  final String? cacheId;

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
        addGlobalUserAvatarCache(widget.cacheId, widget.uid, url);
        return _avatar(url);
      },
      onLoading: _avatar(photoUrl),
    );
  }

  _avatar(String? url) {
    if (url == null || url == "") {
      url = getGlobalUserAvatarCache(widget.cacheId, widget.uid);
    }

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
