import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserDoc
///
/// [builder] 로그인이 되어있는 경우 있고, 사용자 문서가 존재하는 경우 호출되는 콜백 함수.
///
///
/// [documentNotExistBuilder] 사용자가 로그인이 되어있으나, 사용자 문서가 null 인 경우이다.
/// 예를 들면, 로그인 직후, UserService.instance.nullableUser 정보가 읽히기 전에 호출되거나, 또는 실제로
/// 사용자 문서가 존재하지 않는 경우 null 이 되어 이 함수가 호출된다.
///
/// [notLoggedInBuilder] 로그인이 되어있지 않을 때, 빌드할 위젯. 콜백 함수가 지정되지 않으면 빈 위젯을 빌드한다.
///
///
///
///
class UserDoc extends StatelessWidget {
  const UserDoc({super.key, required this.builder, this.notLoggedInBuilder, this.documentNotExistBuilder});
  final Widget Function(User) builder;
  final Widget Function()? notLoggedInBuilder;
  final Widget Function()? documentNotExistBuilder;

  @override
  Widget build(BuildContext context) {
    return UserReady(builder: (user) {
      /// 사용자 로그인 하지 않은 경우,
      if (user == null) {
        if (notLoggedInBuilder != null) {
          return notLoggedInBuilder!();
        } else {
          return const SizedBox.shrink();
        }
      }

      return StreamBuilder<User?>(
        stream: UserService.instance.userDocumentChanges,
        builder: (_, snapshot) {
          final user = snapshot.data;

          /// 주의: 로딩 중, 반짝임(깜빡거림)이 발생할 수 있다.
          if (snapshot.connectionState == ConnectionState.waiting || user == null) {
            return const SizedBox.shrink();
          }

          if (user.uid == '') {
            /// 로그인 했지만, 문서가 존재하지 않는 경우,
            if (documentNotExistBuilder != null) {
              return documentNotExistBuilder!();
            } else {
              return const SizedBox.shrink();
            }
          } else {
            /// 로그인 했고, 사용자 문서가 존재하는 경우,
            return builder(user);
          }
        },
      );
    });
  }
}
