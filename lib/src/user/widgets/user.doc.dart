// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

/// UserDoc
///
/// 다른 사용자의 정보를 한번만 읽어서 전달한다.
/// 화면 깜빡임을 방지하기 위해서 FutureBuilder 나 StreamBiulder 와 같은 것을 사용하지 않는다.
class UserDoc extends StatefulWidget {
  const UserDoc({
    required this.uid,
    required this.builder,
    this.loader = const Center(
      child: SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
        ),
      ),
    ),
    Key? key,
  }) : super(key: key);
  final String uid;
  final Widget loader;
  final Widget Function(UserModel) builder;

  @override
  State<UserDoc> createState() => _UserDocState();
}

class _UserDocState extends State<UserDoc> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    User.instance.get(widget.uid).then((value) {
      if (mounted)
        setState(() {
          user = value;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return widget.loader;
    return widget.builder(user!);
  }
}
