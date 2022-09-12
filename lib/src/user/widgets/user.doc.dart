// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

/// UserDoc
///
/// 다른 사용자의 정보를 한번만 읽어서 전달한다.
/// 사용자가 로그인을 하지 않은 경우, 또는 Anonymous 로 로그인을 한 경우, `signedIn` 으로 검사를 해야 한다.
///
/// 화면 깜빡임을 방지하기 위해서 FutureBuilder 나 StreamBiulder 와 같은 것을 사용하지 않는다.
///
///
class UserDoc extends StatefulWidget {
  const UserDoc({
    required this.uid,
    required this.builder,
    // this.loader = const Center(
    //   child: SizedBox(
    //     width: 10,
    //     height: 10,
    //     child: CircularProgressIndicator.adaptive(
    //       strokeWidth: 2,
    //     ),
    //   ),
    // ),
    Key? key,
  }) : super(key: key);
  final String? uid;
  // final Widget loader;
  final Widget Function(UserModel) builder;

  @override
  State<UserDoc> createState() => _UserDocState();
}

class _UserDocState extends State<UserDoc> {
  UserModel user = UserModel();

  @override
  void initState() {
    super.initState();
    if (widget.uid != null && widget.uid != '') {
      UserService.instance.get(widget.uid!).then((value) {
        if (mounted)
          setState(() {
            user = value;
            print('---> user; $user');
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('builder(user); $user');
    return widget.builder(user);
  }
}
