import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class LoggedOut extends StatelessWidget {
  const LoggedOut({
    super.key,
    required this.builder,
  });

  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    return Login(no: builder);
  }
}
