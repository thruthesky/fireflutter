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
class UserData extends StatelessWidget {
  const UserData({
    super.key,
    required this.uid,
    required this.field,
    required this.builder,
  });

  final String uid;
  final String? field;
  final Function(dynamic data) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: get<Map<String, dynamic>>('users/$uid${field != null ? '/$field' : ''}'),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator.adaptive(),
          );
        }
        if (snapshot.data == null) return const Text('User node does not exists');
        return builder(snapshot.data!);
      },
    );
  }
}
