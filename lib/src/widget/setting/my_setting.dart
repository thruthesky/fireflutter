import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/user_setting/user_setting.dart';
import 'package:flutter/material.dart';

class MySetting extends StatelessWidget with FirebaseHelper {
  const MySetting({
    super.key,
    required this.id,
    this.loader = const CircularProgressIndicator(),
    required this.builder,
  });

  final String id;
  final Widget loader;
  final Widget Function(UserSetting?) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: mySettingCol.where('id', isEqualTo: id).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loader;
        } else if (snapshot.hasError) {
          debugPrint('UserSetting --> error : ${snapshot.error}');
          return const Text('Something went wrong');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return builder(null);
        } else {
          return builder(UserSetting.fromJson(snapshot.data!.docs.first.data() as Map<String, dynamic>));
        }
      },
    );
  }
}
