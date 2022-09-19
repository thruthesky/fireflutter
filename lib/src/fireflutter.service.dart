import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FireFlutterService {
  static FireFlutterService get instance =>
      _instance ?? (_instance = FireFlutterService());
  static FireFlutterService? _instance;

  FirebaseFirestore get db => FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get userCol => db.collection('users');
  DocumentReference get myDoc => userCol.doc(_uid!);
  DocumentReference userDoc(String uid) => userCol.doc(uid);

  DocumentReference tokenDoc(String token) {
    return myDoc.collection('fcm_tokens').doc(token);
  }

  bool get signedIn => UserService.instance.signedIn;
  bool get notSignedIn => UserService.instance.notSignedIn;

  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  CollectionReference get categoryCol => db.collection('categories');
  CollectionReference get postCol => db.collection('posts');
  CollectionReference get commentCol => db.collection('comments');

  CollectionReference get reportCol => db.collection('reports');
  CollectionReference get feedCol => db.collection('feeds');

  // Global (system) settings for app setting.
  CollectionReference get settingDoc => db.collection('settings');

  /// User setting
  /// Note, for the sign-in user's setting, you should use `UserService.instance.settings`
  /// Note, for other user settings, you should use `UserSettings(otherUid, docId)`.
  CollectionReference userSettingsCol(String uid) =>
      userDoc(uid).collection('user_settings');

  /// Get the document of other user's setting.
  /// You cannot write on other's setting but can read.
  /// ```dart
  /// FireFlutterService.instance.userSettingsDoc(uid, "chat.$uid");
  /// UserSettings(otherUid, "chat.$uid")
  /// ```
  DocumentReference userSettingsDoc(String uid, [docId = 'settings']) =>
      userSettingsCol(uid).doc(docId);

  // Forum category menus
  DocumentReference reportDoc(String id) => reportCol.doc(id);

  DocumentReference categoryDoc(String id) {
    return db.collection('categories').doc(id);
  }

  DocumentReference postDoc(String id) {
    return postCol.doc(id);
  }

  ErrorCallback? error;
  AlertCallback? alert;
  ConfirmCallback? confirm;
  dynamic snackbar;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  /// point 를 입력하면 그 point 에 해당하는 레벨을 리턴한다.
  ///
  /// 사용자 포인트를 입력하고 레벨을 표현 할 때 사용하면 된다.
  ///
  /// 포인트와 레벨의 공식
  ///
  /// seed 가 1,00 이면,
  /// 1,000 * 1 + 0 = 1,000 이하 이면, 1 레벨
  /// 1,000 * 2 + 1000 = 3,000 이하 이면, 2 레벨
  /// 1,000 * 3 + 3000 = 6,000 이하 이면, 3 레벨
  /// 1,000 * 4 + 6000 = 10,000 이하 이면, 4 레벨
  /// 1,000 * 5 + 10,000 = 15,000 이하 이면, 5 레벨
  /// 1,000 * 6 + 15,000 = 21,000 이하 이면, 6 레벨
  ///
  /// ... 와 같이 진행 된다.
  int getLevel(int point) {
    const seed = 1000;
    int acc = 0;

    /// 500 레벨 까지
    for (int i = 1; i < 500; i++) {
      acc = seed * i + acc;
      if (point < acc) return i;
    }
    return 0;
  }

  /// Create a report document under `/reports` collection.
  ///
  /// [reporteeUid] is the uid of the reporter.
  ///
  /// [reporteeUid] is the uid of the user being reported.
  ///
  Future<void> report({
    required ReportTarget target,
    required String targetId,
    String? reason,
    String? reporteeUid,
  }) async {
    final uid = UserService.instance.uid;
    final docId = "${target.name}-$targetId-$uid";

    final reportSnap = await reportCol.doc(docId).get();
    if (reportSnap.exists) {
      throw target == ReportTarget.post
          ? ERROR_POST_ALREADY_REPORTED
          : ERROR_COMMENT_ALREADY_REPORTED;
    }
    final data = {
      'reporterUid': uid,
      'target': target.name,
      'targetId': targetId,
      'createdAt': FieldValue.serverTimestamp(),
      if (reason != null) 'reason': reason,
      if (reporteeUid != null) 'reporteeUid': reporteeUid,
    };

    log(data.toString());

    await reportCol.doc(docId).set(data);
  }
}
