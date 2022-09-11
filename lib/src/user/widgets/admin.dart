import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Display [child] widget if the signed-in user is an admin.
class Admin extends StatelessWidget {
  const Admin({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MyDoc(builder: (im) {
      if (im.admin == false)
        return const SizedBox.shrink();
      else
        return child;
    });
  }
}
