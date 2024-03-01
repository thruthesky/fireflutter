import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 로그인 사용자 정보가 변경될 때마다 rebuild 를 하는 위젯
///
///
/// [UserDoc] 위젯은 캐시를 해서, 1회성으로 데이터를 가져오지면,
/// 이 위젯은 로그인을 한 사용자의, 'users/<uid>' 데이터가 변경될 때마다 rebuild 를 한다.
/// 즉, 다른 사용자 정보는 가져오지 않으며, UserService 에서 listen 하는 'users/<uid>' 하위 데이터를 통째로
/// 가져온다. 그래서 여러군데 동시에 쓰기에 부담이 없는 위젯이다.
///
/// 사용자 문서가 로드되지 않은 경우, (주로, 처음 앱을 실행하는 경우) [builder] 로 null 이 전달될 수 있다.
class MyDoc extends StatelessWidget {
  const MyDoc({super.key, required this.builder});

  final Function(UserModel? user) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: UserService.instance.myDataChanges,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator.adaptive(),
          );
        }
        if (snapshot.hasError) {
          dog('error in MyDoc: ${snapshot.error}');
          return const Icon(Icons.error_outline);
        }
        final user = snapshot.data;

        return builder(user);
      },
    );
  }

  /// 로그인한 사용자의 DB 에서 하나의 값을 모니터링 한다.
  ///
  /// 주의, 굳이 이 함수를 쓸 필요없이, [MyDoc] 위젯을 쓰면 된다. [MyDoc] 위젯은 DB 에서 값을 listen 하는
  /// 것이 아니라, [UserService.user] 를 listen 하기 때문에, [MyDoc] 위젯을 쓰면, DB 에서 값을 가져오지
  /// 않기 때문에 더 효율 적이다.
  ///
  /// [onLoading] 은 현재 정보를 바탕으로 호출하므로, 깜빡임에 효율적이다.
  @Deprecated('User MyDoc. MyDoc is more efficient than MyDoc.field()')
  static Widget field(
    String field, {
    required Function(dynamic value) builder,
  }) {
    return UserDoc.fieldSync(
      uid: FirebaseAuth.instance.currentUser!.uid,
      field: field,
      builder: (v) => builder(v),
      onLoading: builder(my?.data[field]),
    );
  }
}
