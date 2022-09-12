import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FireFlutterService {
  static FireFlutterService get instance =>
      _instance ?? (_instance = FireFlutterService());
  static FireFlutterService? _instance;

  ErrorCallback? error;
  AlertCallback? alert;
  ConfirmCallback? confirm;
  dynamic snackbar;

  FirebaseAuth auth = FirebaseAuth.instance;

  late BuildContext context;

  /// 생성자는 한번만 호출된다.
  FireFlutterService() {
    /// 사용자 로그인
    ///
    /// * 사용자 정보를 미리 읽고 listen 해서 문서가 수정 될 대 마다, 사용자 정보를 업데이트 한다.
    auth.authStateChanges().listen((firebaseUser) async {
      ///
      if (firebaseUser == null) {
        log('---> Not signed in. signInAnonymously()');
        UserService.instance.unobserveUserDoc();
        await auth.signInAnonymously();
      } else {
        if (firebaseUser.isAnonymous) {
          log('---> Anonymous signed-in.');
        } else {
          log('---> User signed-in. email: ${firebaseUser.email}, phone: ${firebaseUser.phoneNumber}');

          UserService.instance.get(firebaseUser.uid).then((userDoc) async {
            if (userDoc.exists == false || userDoc.createdAt == null) {
              log('---> The user has no document. create one now');
              await userDoc.update({'createdAt': Timestamp.now()});
            }
          });

          UserService.instance.observeUserDoc();
        }
      }
    });
  }

  /// TODO alert, confirm, error, toast overwrite
  /// alert, confirm, error, toast 등을 기본 것을 사용하고, 별도로 디자인하고 싶다면, 여기서 callback 지정을 할 수 있다.
  /// 이 함수는 여러번 호출될 수 있고, 호출 할 때 마다 다른 값으로 초기화 할 수 있다.
  ///
  init({
    required BuildContext context,
    AlertCallback? alert,
    ConfirmCallback? confirm,
    ErrorCallback? error,
    SnackbarCallback? snackbar,
  }) {
    log('---> FireFlutterService::init()');
    this.context = context;
    this.alert = alert;
    this.confirm = confirm;
    this.error = error;
    this.snackbar = snackbar;
  }
}
