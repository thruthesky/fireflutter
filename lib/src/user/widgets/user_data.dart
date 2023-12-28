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
/// ```dart
/// UserData(
///   uid: message.uid!,
///   field: null,
///   builder: (data) => UserAvatar(
///     user: user,
///     radius: 13,
///     onTap: () => ...,
///   ),
/// ),
/// ```
final _userDataCache = <String, dynamic>{};

class UserData extends StatelessWidget {
  const UserData({
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
          dog('error in UserData: ${snapshot.error}');
          return const Icon(Icons.error_outline);
        }
        if (cache) {
          _userDataCache[path] = snapshot.data;
        }
        return builder(snapshot.data);
      },
    );
  }
}
