import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Cache user data
///
/// 실제로 이 캐시를 사용하면, setState() 를 호출 할 때, 화면 깜빡임이 매우 줄어든다.
final _userDocCache = <String, dynamic>{};

/// Get user data synchroneously.
///
/// 사용자 필드(또는 전체) 값을 가져온다. [UserDoc.sync] 를 사용하면, DB 가 업데이트되면 실시간으로 위젯에 업데이트된다.
///
/// 주의, field 가 null 이면, "users/uid" 통째를 가져오고, field 가 'abc/def' 이면, "users/uid/abc/def" 의 값을 가져온다.
/// 참고, 사용자 정보를 전달 할 때, 사용자 데이터를 통째로 읽어 전달 할 필요 없이, 필요한 데이터 필드만 바로 바로 쓰면 된다.
///
///
/// [cache] 가 true 이면 캐시를 사용한다. 즉, 같은 uid 와 field 에 대한 데이터는 한번만 읽어온다.
/// 캐시는 sync 를 할 때에는 무시된다. 즉, sync 을 안할 때에만 cache 를 사용한다.
///
///
/// 아래의 예제는 사용자 이름을 실시간으로 표시한다.
/// ```dart
/// UserDoc( ... )
/// UserDoc.sync(uid: user.uid, field: 'displayName', builder: (data, $) => Text(data)),
/// UserDoc.field( ... )
/// UserDoc.fieldSync( ...)
/// ```
///
/// ```dart
/// UserDoc(
///   uid: message.uid!,
///   builder: (data) => UserAvatar(
///     user: user,
///     radius: 13,
///     onTap: () => ...,
///   ),
/// ),
/// ```
///
class UserDoc extends StatelessWidget {
  const UserDoc({
    super.key,
    required this.uid,
    required this.builder,
    this.onLoading,
    this.cacheId,
  });

  final String uid;
  final Function(UserModel data) builder;
  final Widget? onLoading;
  final String? cacheId;

  @override
  Widget build(BuildContext context) {
    // cacheId 가 있으면, 캐시를 사용한다.
    if (cacheId != null && _userDocCache.containsKey(uid)) {
      return builder(_userDocCache[uid]);
    }

    return FutureBuilder(
      future: get('users/$uid'),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return onLoading ?? const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          dog('error in UserDoc: ${snapshot.error}');
          return const Icon(Icons.error_outline);
        }

        if (cacheId != null) {
          _userDocCache[uid] = UserModel.fromJson(snapshot.data, uid: uid);
        }

        return builder(UserModel.fromJson(snapshot.data, uid: uid));
      },
    );
  }

  static Widget field({
    dynamic initialData,
    required String uid,
    required String field,
    required Function(dynamic) builder,
    Widget? onLoading,
    String? cacheId,
  }) {
    // Use cached data if [cacheId] is provided.
    if (cacheId != null && _userDocCache.containsKey('$uid/$field')) {
      return builder(_userDocCache['$uid/$field']);
    }

    return FutureBuilder(
      future: get('users/$uid/$field'),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (initialData != null) {
            return builder(initialData);
          } else {
            return onLoading ?? const SizedBox.shrink();
          }
        }
        if (snapshot.hasError) {
          dog('error in UserDoc: ${snapshot.error}');
          return const Icon(Icons.error_outline);
        }

        if (cacheId != null) {
          _userDocCache['$uid/$field'] = snapshot.data;
        }

        return builder(snapshot.data);
      },
    );
  }

  /// 사용자의 특정 필드 하나만 listen 한다.
  ///
  /// 로그인한 사용자 뿐만 아니라, 다른 사용자의 필드를 listen 할 때에도 사용한다.
  ///
  static Widget sync({
    dynamic initialData,
    required String uid,
    required Widget Function(UserModel data) builder,
    Widget? onLoading,
  }) {
    final path = 'users/$uid';

    return Value(
      initialData: initialData,
      path: path,
      builder: (data) => builder(UserModel.fromJson(data, uid: uid)),
      onLoading: onLoading,
    );
  }

  /// 사용자의 특정 필드 하나만 listen 한다.
  ///
  /// 로그인한 사용자 뿐만 아니라, 다른 사용자의 필드를 listen 할 때에도 사용한다.
  ///
  static Widget fieldSync({
    dynamic initialData,
    required String uid,
    required String field,
    required Widget Function(dynamic data) builder,
    Widget? onLoading,
  }) {
    final path = 'users/$uid/$field';

    return Value(
      initialData: initialData,
      path: path,
      builder: builder,
      onLoading: onLoading,
    );
  }
}
