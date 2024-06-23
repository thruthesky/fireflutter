import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 로그인 사용자 정보가 변경될 때마다 rebuild 를 하는 위젯
///
///
/// [UserDoc] 위젯은 캐시를 해서, 1회성으로 데이터를 가져오지면,
/// 이 위젯은 로그인을 한 사용자의, 'users/<uid>' 데이터가 변경될 때마다 rebuild 를 한다.
/// 즉, 다른 사용자 정보는 가져오지 않으며, 현재 사용자가 로그아웃하고, 다른 사용자로 로그인을 해도,
/// 바뀐 사용자의 정보를 가져와 위젯을 표현한다.
///
/// 이 위젯은 UserService 에서 사용자가 Firebase Auth 에 로그인하기를 기다렸다가 로그인을 하면,
/// 'users/<uid>' 하위 데이터를 통째로 가져 온 다음 이벤트를 발생한다. 즉, 사용자가 로그아웃 후
/// 다른 사용자로 로그인을 하면, 이벤트가 발생하여, 이 위젯이 rebuild 된다. 따라서 사용자 로그인 변경을
/// 감지하여 화면을 갱신하는데 사용하기 적당하다.
///
/// 또한 이 위젯은 [UserService.instance.changes] 를 사용하여 사용자의 정보를 매번 DB 에서 가져오지
/// 않고, 내부적으로 캐시하기 때문에, 여러군데 동시에 사용해도 DB 액세스를 많이 하지 않기 때문에, 부담없이
/// 쓰기 좋은 위젯이다.
///
/// 사용자 문서가 로드되지 않은 경우, (주로, 처음 앱을 실행하는 경우) [builder] 로 null 이 전달될 수 있다.
///
/// [initialData] 는 사용자 문서가 로드되지 않은 경우, [builder] 에 전달되는 초기값이다. 자세한 내용은
/// user.md 를 참고한다.
class MyDoc extends StatelessWidget {
  const MyDoc({
    super.key,
    this.initialData,
    required this.builder,
  });

  final User? initialData;
  final Function(User? user) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      initialData: initialData,
      stream: UserService.instance.changes,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.hasData == false) {
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
}
