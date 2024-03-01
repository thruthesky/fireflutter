import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// MyDocReady
///
/// 사용자 문서가 로딩되었는지 확인한다. 단순히, [MyDoc] 위젯을 사용하여, 사용자 문서가 로딩되었는지 확인하는 것으로
/// 사용자 문서가 로딩되었으면, builder(UserModel)이 실행되며, 로딩이 안되었으면, [loading] 이 실행된다.
///
/// [MyDoc] 을 사용하면, builder(UserModel) 가 null 일 수 있으므로, null 체크를 해야 하는데,
/// [MyDocReady] 는 builder(UserModel) 가 null 이 아니므로 조금 더 편리하게 사용 할 수 있다.
///
class MyDocReady extends StatelessWidget {
  const MyDocReady({super.key, required this.builder, this.loading});

  final Widget Function(UserModel) builder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return MyDoc(builder: (my) {
      if (my == null) {
        return loading ?? const SizedBox.shrink();
      }
      return builder(my);
    });
  }
}
