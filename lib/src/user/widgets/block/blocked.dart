import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Blocked extends StatelessWidget {
  const Blocked({
    super.key,
    required this.otherUserUid,
    required this.no,
    required this.yes,
  });

  final String otherUserUid;
  final Widget Function() no;
  final Widget Function() yes;

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (my) => my?.blocked(otherUserUid) == true ? yes() : no(),
    );
  }
}
