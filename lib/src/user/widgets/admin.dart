import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Admin
///
/// 관리자이면, builder 를 실행해서 위젯을 표시한다.
/// 관리자가 아니면, notAdminBuilder 를 실행해서 위젯을 표시하거나 또는 빈 화면을 표시한다.
class IsAdmin extends StatelessWidget {
  const IsAdmin({super.key, required this.builder, this.notAdminBuilder});
  final Function() builder;
  final Function()? notAdminBuilder;

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (my) => isAdmin
          ? builder()
          : (notAdminBuilder?.call() ?? const SizedBox.shrink()),
    );
  }
}
