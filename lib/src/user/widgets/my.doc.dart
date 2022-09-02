import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

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
  UserModel user = UserModel();
  StreamSubscription? userProfileSubscription;

  @override
  void initState() {
    super.initState();

    userProfileSubscription =
        User.instance.doc.snapshots().listen((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        user = UserModel.fromSnapshot(documentSnapshot);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    userProfileSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(user);
  }
}
