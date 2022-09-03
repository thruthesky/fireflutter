import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 나의 문서 `/users/<uid>` 를 listen 하고 업데이트가 있으면 build 함수를 호출한다.
///
/// 사용자 로그인을 하지 않았거나, 사용자 문서가 존재하지 않으면,
///   builder 파라메타로 전달되는 userModel.exists 는 false 가 되고 각종 속성은 기본 값을 가진다.
/// 사용자가 로그 아웃이나 계정을 변경해도 이전 사용자 문서 listen 을 cancel 하고 새로 로그인한 사용자의 문서를 잘 listen 한다.
class MyDoc extends StatefulWidget {
  const MyDoc({
    Key? key,
    required this.builder,
  }) : super(key: key);
  final Widget Function(UserModel) builder;

  @override
  State<MyDoc> createState() => _MyDocState();
}

class _MyDocState extends State<MyDoc> {
  UserModel userModel = UserModel();
  StreamSubscription? userDocumentSubscription;
  late StreamSubscription authSubscription;

  @override
  void initState() {
    super.initState();

    authSubscription =
        Firebase.FirebaseAuth.instance.authStateChanges().listen((user) {
      userDocumentSubscription?.cancel();
      userDocumentSubscription = User.instance.doc
          .snapshots()
          .listen((DocumentSnapshot snapshot) async {
        userModel = UserModel.fromSnapshot(snapshot);
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    userDocumentSubscription?.cancel();
    authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(userModel);
  }
}
