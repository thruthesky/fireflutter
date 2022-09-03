import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class UserSignedOut extends StatelessWidget {
  const UserSignedOut({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MyDoc(builder: (u) {
      if (u.notSignedIn)
        return child;
      else
        return SizedBox.shrink();
    });
  }
}
