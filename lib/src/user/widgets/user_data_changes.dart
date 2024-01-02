import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// 로그인 사용자 정보가 변경될 때마다 rebuild 를 하는 위젯
///
///
/// [UserData] 위젯은 캐시를 해서, 1회성으로 데이터를 가져오지면,
/// 이 위젯은 로그인을 한 사용자의, 'users/<uid>' 데이터가 변경될 때마다 rebuild 를 한다.
/// 즉, 다른 사용자 정보는 가져오지 않으며, UserService 에서 listen 하는 'users/<uid>' 하위 데이터를 통째로
/// 가져온다. 그래서 여러군데 동시에 쓰기에 부담이 없는 위젯이다.
class MyDataChanges extends StatelessWidget {
  const MyDataChanges({super.key, required this.builder});

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
          dog('error in MyDataChanges: ${snapshot.error}');
          return const Icon(Icons.error_outline);
        }
        final user = snapshot.data;
        return builder(user);
      },
    );
  }
}
