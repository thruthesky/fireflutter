import 'package:firebase_auth/firebase_auth.dart' as fa;
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
/// [onLoading] is the callback widget builder function that is called when the data is being loaded.
/// 로그인이 되어있지 않을 때, 빌드할 위젯. 콜백 함수가 지정되지 않으면 빈 위젯을 빌드한다.
///
/// [live] If [live] is set to true, the builder function is called every time the user document changes.
/// Or if [live] is set to false, the builder function is called only once.
/// true 이면, 사용자 문서가 변경될 때마다, builder 함수가 호출된다. false 이면 한번만 호출된다.
///
///
class UserDoc extends StatelessWidget {
  const UserDoc({
    super.key,
    required this.builder,
    this.notLoggedInBuilder,
    this.documentNotExistBuilder,
    this.onLoading,
    this.live = true,
  });
  final Widget Function(User) builder;
  final Widget Function()? notLoggedInBuilder;
  final Widget Function()? documentNotExistBuilder;
  final Widget? onLoading;

  final bool live;

  @override
  Widget build(BuildContext context) {
    // Check if the user has logged in or not
    return StreamBuilder<fa.User?>(
      stream: fa.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // in loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return onLoading ?? const SizedBox.shrink();
        }

        final user = snapshot.data;

        // if user has not logged in, return empty widget or notLoggedInBuilder callback widget.
        if (user == null) {
          return notLoggedInBuilder?.call() ?? const SizedBox.shrink();
        }

        // if the user has logged in,
        return live
            // live update
            ? StreamBuilder<User?>(
                stream: UserService.instance.documentChanges,
                builder: buildStreamWidget,
              )
            // update one time
            : FutureBuilder<User?>(
                future: UserService.instance.get(user.uid),
                builder: buildStreamWidget,
              );
      },
    );
  }

  Widget buildStreamWidget(BuildContext _, AsyncSnapshot<User?> snapshot) {
    // in loading...
    if (snapshot.connectionState == ConnectionState.waiting) {
      return onLoading ?? const SizedBox.shrink();
    }

    final user = snapshot.data;

    /// 주의: 로딩 중, 반짝임(깜빡거림)이 발생할 수 있다.
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox.shrink();
    }

    /// 주의: 사용자 문서가 null 인 경우는 앱 실행 직후, UserService.instance.nullableUser
    /// 정보가 읽히기 전에 호출된 경우 뿐이다. 위에서 이미 로그인 확인을 했다.
    if (user == null) {
      return notLoggedInBuilder?.call() ?? const SizedBox.shrink();
    }

    /// 로그인 했지만, 문서가 존재하지 않는 경우,
    if (user.exists == false) {
      return documentNotExistBuilder?.call() ?? const SizedBox.shrink();
    }

    /// 로그인 했고, 사용자 문서가 존재하는 경우,
    return builder(user);
  }
}
