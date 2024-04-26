import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserSettingValue extends StatelessWidget {
  const UserSettingValue({
    super.key,
    required this.field,
    required this.builder,
  });

  final String field;
  final Widget Function(dynamic, DatabaseReference) builder;

  @override
  Widget build(BuildContext context) {
    final ref = UserSetting.nodeRef.child(myUid!).child(field);
    return Value(
        ref: ref,
        builder: (value) {
          return builder(value, ref);
        });
  }
}
