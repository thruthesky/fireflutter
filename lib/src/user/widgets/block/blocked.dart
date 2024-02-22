import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class Blocked extends StatelessWidget {
  const Blocked(
      {super.key, required this.uid, required this.no, required this.yes});

  final String uid;
  final Widget Function() no;
  final Widget Function() yes;

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (my) => my!.blocked(uid) == true ? yes() : no(),
    );
  }
}
