import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserDoc
///
///
/// 활용도가 매우 높은 위젯이다.
///
/// [uid] 와 [user] 값이 입력되지 않으면 현재 사용자 문서를 firestore /users 에서 읽어 온다. [live] 에
/// 따라 FutureBuilder 또는 StreamBuilder 로 위젯을 빌드한다. [live] 가 true 이면, 사용자 로그인
/// 로그아웃 할 때, 새로운 사용자 문서를 가져와 빌드한다.
///
/// [uid] 와 [user] 값이 입력되면, realtime database 의 /users 에서 해당 사용자 문서를 읽어온다.
/// 이 때, [uid] 또는 [user] 가 현재 로그인한 사용자의 것이라도 RTDB 의 /users 에서 사용자 데이터를
/// 가져온다.
///
/// [uid] 과 [user] 둘다 지정되지 않고, 현재 사용자가 로그인 되지 않은 상태이면, [notLoggedInBuilder]
/// 콜백을 호출 해서 위젯을 표시 할 수 있다.
///
/// [builder] 사용자 문서가 존재하는 경우 호출되는 콜백 함수.
///
/// [user] 화면 반짝임을 줄이기 위해서, 사용자 model 이 있으면 전달하면 된다. 이 때, onLoaing 은 호출되지 않고,
/// 입력된 user model 을 사용해서 화면에 그린다.
/// ```dart
/// UserDoc(
///   user: widget.user,
///   builder: (user) {
///```
///
/// [user] 에 값을 지정하고, [uid] 값을 지정하지 않으면, [user] 의 uid 를 사용해서 화면을 그린다.
/// [uid] 와 [user] 둘 다 지정하면, [user] 의 uid 를 사용해서 사용자 문서를 가져온다. 즉, [uid] 와
/// [user.uid] 가 다른 경우, [user.uid] 가 사용되는 것이다.
///
/// [onLoading] is the widget to be used when the data is being loaded. It's not a callback.
///
/// [live] 는 기본 값이 false 이다. true 이면 실시간 업데이트를 화면에 표시하며, false 이면 실시간으로 화면에 표시하지 않는다.
///
/// TODO for checking because code is revised - christian
class UserDoc extends StatelessWidget {
  const UserDoc({
    super.key,
    this.uid,
    required this.builder,
    this.onLoading,
    this.live = false,
    this.user,
    this.notLoggedInBuilder,
  });
  final String? uid;
  final Widget Function(User) builder;
  final Widget? onLoading;
  final Widget Function()? notLoggedInBuilder;

  final User? user;

  final bool live;

  String get currentUserUid => fa.FirebaseAuth.instance.currentUser!.uid;

  String? get userUid => user?.uid ?? uid;

  @override
  Widget build(BuildContext context) {
    // 현재 사용자 (uid 와 user 가 null)
    if (uid == null && user == null) {
      // 실시간 업데이트가 아니면,
      if (live == false) {
        // 현재 사용자, 실시간 아님, 로그인 안 했음. Not logged in 위젯 표시
        if (fa.FirebaseAuth.instance.currentUser == null) {
          return notLoggedInBuilder?.call() ?? const SizedBox.shrink();
        }
        // 현재 사용자, 실시간 아님, 로그인 했음
        // 로그인을 했으면, firestore /users collection 에서 데이터를 가져와 biuld 한다.
        return FutureBuilder<User?>(
          future: User.get(currentUserUid),
          builder: buildStreamWidget,
        );
      }
      // 현재 사용자, 실시간 업데이트이면, 로그인/로그아웃 할 때 마다 감시해서 다시 빌드
      return StreamBuilder(
        stream: fa.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 로딩 중이면,
          if (snapshot.connectionState == ConnectionState.waiting) {
            return onLoading ?? const CircularProgressIndicator.adaptive();
          }
          // 에러가 있으면,
          if (snapshot.hasError) {
            return Text('Something went wrong - ${snapshot.error}');
          }
          // 현재 사용자, 실시간, 로그인을 안했으면, Not logged in 위젯 표시
          if (snapshot.data == null) {
            return notLoggedInBuilder?.call() ?? const SizedBox.shrink();
          }
          // 현재, 사용자, 실시간, 로그인 했으면,
          // 현재 사용자의 문서를 실시간으로 Firestore /users collection 에서 데이터를 가져와 biuld 한다.
          return StreamBuilder<User?>(
            stream: UserService.instance.snapshot,
            builder: buildStreamWidget,
          );
        },
      );
    }
    // uid 또는 user 가 지정되면, RTDB 의 /users 에서 해당 사용자 문서를 가져와서 build 한다.
    // 참고로, uid 또는 user 가 현재 사용자 일 수 있다. uid/user 가 현재 사용자 값이라 해도, RTDB 에서 가져온다.

    if (live == false) {
      return FutureBuilder<User?>(
        future: UserService.instance.get(userUid!), // 캐시된 사용자 정보
        builder: buildStreamWidget,
      );
    }
    // 실시간 업데이트
    return StreamBuilder<User?>(
      stream: UserService.instance.snapshotOther(userUid!),
      builder: buildStreamWidget,
    );
  }

  Widget buildStreamWidget(BuildContext _, AsyncSnapshot<User?> snapshot) {
    /// 주의: 로딩 중, 반짝임(깜빡거림)이 발생할 수 있다.
    if (snapshot.connectionState == ConnectionState.waiting) {
      // 로딩 중이면, 반짝임을 없애고, 빠르게 랜더링을 하기 위해서, 입력된 user model 로 화면을 그린다.

      if (user != null) {
        return builder(user!);
      } else {
        return onLoading ?? const SizedBox.shrink();
      }
    }

    final userModel = snapshot.data;

    /// 문서를 가져왔지만, 문서가 null 이거나 문서가 존재하지 않는 경우, user.exists == false 가 된다.
    if (snapshot.hasData == false || snapshot.data?.exists == false || userModel == null) {
      return builder(User.notExists());
    }

    return builder(userModel);
  }
}
