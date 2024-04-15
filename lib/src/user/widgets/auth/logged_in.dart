import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class LoggedIn extends StatelessWidget {
  const LoggedIn({super.key, required this.builder});

  final Widget Function(String) builder;

  @override
  Widget build(BuildContext context) {
    return Login(yes: builder);
  }
}
