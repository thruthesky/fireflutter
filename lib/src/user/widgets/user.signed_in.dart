import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

/// 회원 로그인을 했을 때, 보여줄 위젯 또는 빌더
///
/// 이 위젯을 적극 활용한다.
class UserSignedIn extends StatelessWidget {
  const UserSignedIn({
    Key? key,
    this.child,
    this.builder,
  }) : super(key: key);
  final Widget? child;
  final Widget Function(UserModel)? builder;

  @override
  Widget build(BuildContext context) {
    return MyDoc(builder: (u) {
      if (u.signedIn) {
        if (child != null) {
          return child!;
        } else {
          return builder!(u);
        }
      } else
        return SizedBox.shrink();
    });
  }
}
