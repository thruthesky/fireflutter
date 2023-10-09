import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserDoc
///
/// Build widget based on the user document changes.
///
/// If [uid] and [user] are not set, then it reads the current user document from firestore /users.
/// Depending on the [live] value, it builds the widget with FutureBuilder or StreamBuilder.
/// If [live] is true, it builds with StreamBuilder, otherwise, it builds with FutureBuilder.
///
/// If [uid] and [user] are set, then it reads the user document from the user document.
///
/// If [uid] and [user] are not set and the user is not logged in, then it calls [notLoggedInBuilder]
/// callback to build the widget for not logged in user.
///
/// [builder] is the callback function to be called when the user document exists.
///
/// If both of [uid] and [user] is set, then [uid] is ignored.
///
/// If [user] is set, then [onLoading] is ignored. That means, you can fast render the widget without flickering.
///
/// ```dart
/// UserDoc(
///   user: widget.user,
///   builder: (user) {
///```
///
///
/// [onLoading] is the widget to be used when the data is being loaded. It's not a callback.
///
/// [live] is false by default. If it's true, then it updates the widget in real time on the user document udpate.
///
/// [notLoggedInBuilder] is the callback function to be called when the user is
/// not logged in. This callback works only when [uid] and [user] is null.
class UserDoc extends StatelessWidget {
  const UserDoc({
    super.key,
    this.uid,
    this.user,
    required this.builder,
    this.onLoading,
    this.live = false,
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
  bool get isCurrentUser => uid == null && user == null;

  @override
  Widget build(BuildContext context) {
    // I am the one who see the document.
    if (isCurrentUser) {
      //
      if (live == true) {
        // if it's live, assume that the user may sign-in in any seconds.
        return StreamBuilder(
          stream: fa.FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // While loading, (Meaning, while the user is logging in. The user is in the middle of loggin in.)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return onLoading ?? const CircularProgressIndicator.adaptive();
            }
            // Error on loggin in.
            if (snapshot.hasError) {
              return Text('Something went wrong - ${snapshot.error}');
            }
            // Login process has binished, but the user didn't logged in.
            if (snapshot.data == null) {
              return notLoggedInBuilder?.call() ?? const SizedBox.shrink();
            }
            // The user logged in.
            // Return stream builder to build the widget in real time.
            return StreamBuilder<User?>(
              stream: UserService.instance.snapshot,
              builder: buildStreamWidget,
            );
          },
        );
      } else {
        // If it's not live update, just build the widget only one time.

        // If I dind't logged in,
        if (fa.FirebaseAuth.instance.currentUser == null) {
          return notLoggedInBuilder?.call() ?? const SizedBox.shrink();
        }
        // If I logged in,
        return FutureBuilder<User?>(
          future: User.get(currentUserUid),
          builder: buildStreamWidget,
        );
      }
    } else {
      //
      // Other user
      //
      // Note,
      if (live == true) {
        // 실시간 업데이트
        return StreamBuilder<User?>(
          stream: UserService.instance.snapshotOther(userUid!),
          builder: buildStreamWidget,
        );
      } else {
        return FutureBuilder<User?>(
          future: UserService.instance.get(userUid!), // 캐시된 사용자 정보
          builder: buildStreamWidget,
        );
      }
    }
  }

  Widget buildStreamWidget(BuildContext _, AsyncSnapshot<User?> snapshot) {
    /// 주의: 로딩 중, 반짝임(깜빡거림)이 발생할 수 있다.
    if (snapshot.connectionState == ConnectionState.waiting) {
      // 로딩 중이면, 반짝임을 없애고, 빠르게 랜더링을 하기 위해서, 입력된 user model 로 화면을 그린다.
      if (user == null) return onLoading ?? const SizedBox.shrink();
      return builder(user!);
    }

    final userModel = snapshot.data;

    /// 문서를 가져왔지만, 문서가 null 이거나 문서가 존재하지 않는 경우, user.exists == false 가 된다.
    if (snapshot.hasData == false || userModel == null) {
      ///
      /// It passes the user model with the current time when there is no user document.
      return builder(User.nonExistent());
    }
    return builder(userModel);
  }
}
