import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserDoc
///
/// 활용도가 매우 높은 위젯이다.
///
/// [uid] 만약 [uid] 가 설정되면, 해당 사용자 문서를 listen(또는 get) 한다. [uid] 가 설정 안되면 로그인한
/// 사용자의 문서를 읽어오거나 listen(또는 get) 한다.
/// 주의, [uid] 값이 지정되지 않았다면, 나의 정보 문서를 읽는데, `/users` 컬렉션에서 읽는다.
/// 주의, [uid] 값이 주어지면, realtime database 의 `/users` 에서 값을 읽는다.
/// 주의, [uid] 값도 지정되지 않았고, 현재 사용자도 로그인하지 않았다면, 에러(null check operator error)가 발생한다.
/// 즉, [uid] 값을 지정하지 않으면 나의 정보, 아니면 다른 사람 정보인데, 다른 사람 정보는 firestore 의
/// /users 컬렉션이 security permission 으로 막혀 있어서 rtdb 에서 가져온다.
///
/// [builder] 사용자 문서가 존재하는 경우 호출되는 콜백 함수.
///
/// [user] 화면 반짝임을 줄이기 위해서, 사용자 model 이 있으면 전달하면 된다. 이 때, onLoaing 은 호출되지 않고,
/// 입력된 user model 을 사용해서 화면에 그린다.
///
/// [documentNotExistBuilder] 사용자 문서 존재하지 않는 경우 호출되는 콜백 함수
/// 문서를 읽고 있는 동안에는 이 함수가 호출되지 않고, 완전히 읽고 난 다음 문서가 없으면, 호출된다.
///
/// [onLoading] is the widget to be used when the data is being loaded. It's not a callback.
///
/// [live] 는 기본 값이 null 이다. true 이면 실시간 업데이트를 화면에 표시하며, false 이면 실시간으로 화면에 표시하지 않는다.
/// [live] 와 [uid] 가 모두 생략(null)되면, 나의 정보를 실시간 업데이트한다. 나의 정보는 firestore /users 에서 가져온다.
/// [live] 가 null 이고, [uid] 가 입력되면, 다른 사용자 정보를 가져오므로, 실시간 업데이트를 하지 않는다.
/// 그 외에는 [live] 값에 따른다. true 이면 실시간 업데이트, false 이면 실시간 업데이트를 하지 않는다.
///
///
/// 로그인한 사용자의 uid 와 다르면, 즉, 다른 사용자 정보를 보여주는 경우, 자동으로
/// false 가 되어 실시간 업데이트를 하지 않는다.
/// 명시적으로 live 업데이트를 하고 싶다면
///
///
///
class UserDoc extends StatelessWidget {
  const UserDoc({
    super.key,
    this.uid,
    required this.builder,
    this.documentNotExistBuilder,
    this.onLoading,
    this.live,
    this.user,
  });
  final String? uid;
  final Widget Function(User) builder;
  final Widget Function()? documentNotExistBuilder;
  final Widget? onLoading;
  final User? user;

  final bool? live;

  String get currentUserUid => fa.FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return live ?? uid == null
        // live update
        ? StreamBuilder<User?>(
            stream: uid == null
                ? UserService.instance.col.doc(currentUserUid).snapshots().map((doc) => User.fromDocumentSnapshot(doc))
                : UserService.instance.rtdb.ref().child('/users/$uid').onValue.map(
                    (event) {
                      return User.fromMap(
                          map: Map<String, dynamic>.from((event.snapshot.value ?? {}) as Map), id: uid!);
                    },
                  ),
            builder: buildStreamWidget,
          )
        // update one time
        : FutureBuilder<User?>(
            future: UserService.instance.get(uid ?? currentUserUid, sync: uid != null),
            builder: buildStreamWidget,
          );
  }

  Widget buildStreamWidget(BuildContext _, AsyncSnapshot<User?> snapshot) {
    /// 주의: 로딩 중, 반짝임(깜빡거림)이 발생할 수 있다.
    if (snapshot.connectionState == ConnectionState.waiting) {
      // 로딩 중이면, 반짝임을 없애고, 빠르게 랜더링을 하기 위해서, 입력된 user model 로 화면을 그린다.
      if (user != null) {
        return builder(user!);
      }
      return onLoading ?? const SizedBox.shrink();
    }

    final userModel = snapshot.data;

    /// 문서를 가져왔지만, 문서가 null 이거나 문서가 존재하지 않는 경우,
    if (userModel?.exists == false || userModel == null) {
      return documentNotExistBuilder?.call() ?? const SizedBox.shrink();
    }

    /// 로그인 했고, 사용자 문서가 존재하는 경우,
    return builder(userModel);
  }
}
