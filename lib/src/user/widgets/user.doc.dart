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
/// [useCache] 값이 false 이면, 캐시한 값을 사용하지 않는다. 즉, 사용자 정보를 서버에서 매번 가져와서 보여 준다.
/// [useCache] 값이 null 로 입력되면, [uid] 가 로그인한 사용자의 uid 와 동일하면, 매번 서버로 부터 가져와서
/// 회원 정보를 보여주고, 아니면, 캐시한 사용자 정보를 보여준다.
///
class UserDoc extends StatefulWidget {
  const UserDoc({
    required this.uid,
    this.useCache,
    required this.builder,
    Key? key,
  }) : super(key: key);
  final String? uid;
  final bool? useCache;
  // final Widget loader;
  final Widget Function(UserModel) builder;

  @override
  State<UserDoc> createState() => _UserDocState();
}

class _UserDocState extends State<UserDoc> {
  UserModel user = UserModel();

  bool get useCache {
    if (widget.useCache == null) {
      return widget.uid != UserService.instance.uid;
    } else {
      return widget.useCache!;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.uid != null && widget.uid != '') {
      UserService.instance.get(widget.uid!, cache: useCache).then((value) {
        if (mounted)
          setState(() {
            user = value;
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('builder(user); $user');
    return widget.builder(user);
  }
}
