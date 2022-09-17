import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Rebuild the widget when the settings are changed.
///
/// The data of the setting docuemnt will be passed over builder function.
/// If the document does not exists, the settings passed to builder will be a null.
///
/// 주의, 이 위젯은 사용자 UID 값이 존재해야만 올바로 동작한다. 최소한 Anonymous 로 로그인을 해야 한다.
/// 만약, 앱이 최소 설치되어 실행되거나 기타 로그아웃 한 상태에서 Anonymous 로 로그인을 하지 않았다면, 즉,
/// 사용자가 완전히 로그인하지 않은 상태라면, uid 값이 없어서 null 또는 empty document path 등의
/// 에러가 발생한다. 그래서 FirebaseAuth.instance.authStateChanges() 를 사용해서 최소한 Anonymous
/// 로 로그인을 했는지 확인한다.
class MySettingsBuilder extends StatelessWidget {
  const MySettingsBuilder(
      {super.key, this.id = 'settings', required this.builder});

  final Widget Function(Map<String, dynamic>? settings) builder;
  final String id;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          }
          if (snap.hasData == false) {
            return SizedBox.shrink();
          }
          if (snap.hasError) {
            return Text(snap.error.toString());
          }

          if (snap.data == null) {
            return SizedBox.shrink();
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(UserService.instance.uid!)
                  .collection('user_settings')
                  .doc(id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive();
                }
                if (snapshot.hasError) {
                  log("MySettingsBuiler($id) error: ${snapshot.error}");
                  return Text(snapshot.error.toString());
                }

                Map<String, dynamic>? settings;
                if (snapshot.data != null && snapshot.data?.exists == true) {
                  settings = snapshot.data?.data() as Map<String, dynamic>;
                }
                return builder(settings);
              });
        });
  }
}
