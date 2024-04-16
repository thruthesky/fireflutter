import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminService {
  static AdminService? _instance;
  static AdminService get instance => _instance ??= AdminService._();

  DatabaseReference get adminRef =>
      FirebaseDatabase.instance.ref().child('admins');

  Map<String, dynamic> admins = {};

  AdminService._() {
    dog('--> AdminService._()');
  }

  /// 관리자 서비스 초기화
  ///
  /// 관리자 목록을 가져와 메모리에 넣어 놓는다. 그리고 실시간 업데이트를 한다.
  init() {
    dog('--> AdminService.init()');
    dog('--> Listen to admin list');

    adminRef.onValue.listen((event) {
      dog('--> AdminService.init() adminRef.onValue.listen()');

      if (event.snapshot.value == null) {
        return;
      }

      admins = Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  showDashboard({required BuildContext context}) {
    dog('--> AdminService.showDashboard()');
    return showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => const AdminDashBoardScreen(),
    );
  }

  showUserList({required BuildContext context}) {
    dog('--> AdminService.showDashboard()');
    return showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => const AdminUserListScreen(),
    );
  }

  showUserUpdate({required BuildContext context, required String uid}) {
    dog('--> AdminService.showDashboard()');
    return showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => AdminUserUpdateScreen(
        uid: uid,
      ),
    );
  }

  /// ## Mirror Backfill RTDB to Firestore
  ///
  /// This function calls the cloud function mirrorBackfillRtdToFirestore
  /// that will copy RTDB's post, comments, and users to Firestore's post,
  /// comments, and users collections.
  ///
  /// Be noted that the cloud function must be deployed.
  ///
  /// **Be warned that this may cost lots of data transfer from RTDB, and**
  /// **lots of write in Firestore, so be careful when using this.**
  Future<HttpsCallableResult> mirrorBackfillRtdbToFirestore() async {
    return await FirebaseFunctions.instanceFor(
      region: FireFlutterService.instance.cloudFunctionRegion,
    ).httpsCallable('mirrorBackfillRtdbToFirestore').call();
  }
}
