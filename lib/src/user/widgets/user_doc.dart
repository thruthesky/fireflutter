import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Get user data from 'users/uid' node.
/// 사용자 필드(또는 전체) 값을 가져온다.
///
/// 주의, field 가 null 이면, "users/uid" 통째를 가져오고, field 가 'abc/def' 이면, "users/uid/abc/def" 의 값을 가져온다.
/// 참고, 이러한 이유로, 사용자 정보를 전달 할 때, 사용자 데이터를 통째로 읽어 전달 할 필요 없이, 필요한 데이터 필드만 바로 바로 쓰면 된다.
///
/// Use this widget to get user data as FutureBuilder only if you know the user's uid.
///
/// [cache] 가 true 이면 캐시를 사용한다. 즉, 같은 uid 와 field 에 대한 데이터는 한번만 읽어온다.
///
/// [sync] 를 사용하면, FutureBuilder 대신에 Database 를 사용한다. 즉, 데이터가 변경되면, 자동으로 리빌드 된다.
/// 이 때, [cache] 는 무시된다.
///
/// 아래의 예제는 사용자 이름을 실시간으로 표시한다.
/// ```dart
/// UserDoc.sync(uid: user.uid, field: 'displayName', builder: (data, $) => Text(data)),
/// ```
///
/// ```dart
/// UserDoc(
///   uid: message.uid!,
///   field: null,
///   builder: (data) => UserAvatar(
///     user: user,
///     radius: 13,
///     onTap: () => ...,
///   ),
/// ),
/// ```
///
final _userDataCache = <String, dynamic>{};

class UserDoc extends StatelessWidget {
  const UserDoc({
    super.key,
    required this.uid,
    required this.field,
    required this.builder,
    this.cache = true,
  });

  final String uid;
  final String? field;
  final Function(dynamic data) builder;
  final bool cache;

  @override
  Widget build(BuildContext context) {
    final path = 'users/$uid${field != null ? '/$field' : ''}';

    if (cache && _userDataCache.containsKey(path)) {
      return builder(_userDataCache[path]);
    }
    return FutureBuilder(
      future: get(path),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator.adaptive(),
          );
        }
        if (snapshot.hasError) {
          dog('error in UserDoc: ${snapshot.error}');
          return const Icon(Icons.error_outline);
        }
        if (cache) {
          _userDataCache[path] = snapshot.data;
        }
        return builder(snapshot.data);
      },
    );
  }

  static Widget sync({
    required String uid,
    String? field,
    required Widget Function(dynamic data) builder,
  }) {
    final path = 'users/$uid${field != null ? '/$field' : ''}';

    return Database(path: path, builder: (a, b) => builder(a));
  }
}
