import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FireFlutter {
  static FireFlutter get instance => _instance ?? (_instance = FireFlutter());
  static FireFlutter? _instance;

  late ErrorCallback error;
  late AlertCallback alert;
  late ConfirmCallback confirm;
  late dynamic toast;

  FirebaseAuth auth = FirebaseAuth.instance;

  late BuildContext context;

  /// 생성자는 한번만 호출된다.
  FireFlutter() {
    log('---> FireFlutter::constructor()');

    /// 사용자 로그인
    ///
    /// * 사용자 정보를 미리 읽고 listen 해서 문서가 수정 될 대 마다, 사용자 정보를 업데이트 한다.
    auth.authStateChanges().listen((firebaseUser) async {
      ///
      if (firebaseUser == null) {
        log('---> Not signed in. signInAnonymously()');
        await auth.signInAnonymously();
      } else {
        if (firebaseUser.isAnonymous) {
          log('---> Anonymous signed-in.');
        } else {
          log('---> User signed-in. email: ${firebaseUser.email}, phone: ${firebaseUser.phoneNumber}');

          // UserService.instance.observeUserDoc();
          final userDoc = await UserService.instance.get(firebaseUser.uid);
          if (userDoc.exists == false || userDoc.createdAt == null) {
            userDoc.update({'createdAt': Timestamp.now()});
          }
        }
      }
    });
  }

  /// alert, confir, error, toast 등을 필요할 때, callback 으로 받아 처리한다.
  /// init() 은 반드시 호출하도록 한다. 그래서, instance 가 생성되고, 사용자 로그인을 처리한다.
  /// 이 함수는 여러번 호출될 수 있고, 호출 할 때 마다 다른 값으로 초기화 할 수 있다.
  ///
  /// [context] 는 각종 다이얼로그나 스낵바, Navigator.pop() 등에 사용되는 것으로
  /// GlobalKey<NavigatorState>() 를 MaterialApp 에 연결한 state context 를 지정하거나
  /// Get 상태 관리자를 쓴다면 Get.content 를 지정해도 된다.
  init({required BuildContext context}) {
    log('---> FireFlutter::init()');
    this.context = context;
  }
}
