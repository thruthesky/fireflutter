import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// MyDoc
///
/// myDoc is a wrapper widget of UserDoc widget.
class MyDoc extends StatelessWidget {
  const MyDoc(
      {super.key, required this.builder, this.my, this.notLoggedInBuilder});

  final Widget Function(User) builder;
  final User? my;
  final Widget Function()? notLoggedInBuilder;

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      user: my,
      live: true,
      notLoggedInBuilder: notLoggedInBuilder,
      builder: builder,
    );
  }
}
