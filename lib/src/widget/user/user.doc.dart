import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserDoc
///
/// [uid] 만약 [uid] 가 설정되면, 해당 사용자 문서를 listen(또는 get) 한다. [uid] 가 설정 안되면 로그인한
/// 사용자의 문서를 읽어오거나 listen(또는 get) 한다.
/// 주의, [uid] 값이 지정되지 않았다면, 현재 사용자의 문서를 읽는데, 현재 사용자도 로그인하지 않았다면,
/// null check operator error 가 발생한다.
///
/// [builder] 사용자 문서가 존재하는 경우 호출되는 콜백 함수.
///
///
/// [documentNotExistBuilder] 사용자 문서 존재하지 않는 경우 호출되는 콜백 함수
/// 문서를 읽고 있는 동안에는 이 함수가 호출되지 않고, 완전히 읽고 난 다음 문서가 없으면, 호출된다.
///
/// [onLoading] is the widget to be used when the data is being loaded. It's not a callback.
///
/// [live] If [live] is set to true, the builder function is called every time the user document changes.
/// Or if [live] is set to false, the builder function is called only once.
/// true 이면, 사용자 문서가 변경될 때마다, builder 함수가 호출된다. false 이면 한번만 호출된다.
///
///
class UserDoc extends StatelessWidget {
  const UserDoc({
    super.key,
    this.uid,
    required this.builder,
    this.documentNotExistBuilder,
    this.onLoading,
    this.live = true,
  });
  final String? uid;
  final Widget Function(User) builder;
  final Widget Function()? documentNotExistBuilder;
  final Widget? onLoading;

  final bool live;

  String get currentUserUid => fa.FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    // if the user has logged in,
    return live
        // live update
        ? StreamBuilder<User?>(
            stream: UserService.instance.col
                .doc(uid ?? currentUserUid)
                .snapshots()
                .map((doc) => User.fromDocumentSnapshot(doc)),
            builder: buildStreamWidget,
          )
        // update one time
        : FutureBuilder<User?>(
            future: UserService.instance.get(uid ?? currentUserUid),
            builder: buildStreamWidget,
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
      return onLoading ?? const SizedBox.shrink();
    }

    /// 문서를 가져왔지만, 문서가 null 이거나 문서가 존재하지 않는 경우,
    if (user?.exists == false) {
      return documentNotExistBuilder?.call() ?? const SizedBox.shrink();
    }

    /// 로그인 했고, 사용자 문서가 존재하는 경우,
    return builder(user!);
  }
}
