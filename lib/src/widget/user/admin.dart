import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Admin extends StatelessWidget {
  const Admin({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return UserDoc(builder: (user) => user.isAdmin == true ? child : const SizedBox());
  }
}
