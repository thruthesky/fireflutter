import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AdminService {
  static AdminService? _instance;
  static AdminService get instance => _instance ??= AdminService._();

  DatabaseReference get adminRef =>
      FirebaseDatabase.instance.ref().child('admins');

  Map<String, dynamic> adminsValue = {};
  List<String> get admins => adminsValue.keys.toList();

  BehaviorSubject<bool> isAdminStream = BehaviorSubject<bool>.seeded(false);

  bool get isAdmin {
    return admins.contains(myUid);
  }

  /// 채팅 관리자의 uid를 가져온다.
  ///
  /// 채팅 관리자는 'chat' 권한을 가진 사용자 중에서 가장 먼저 나오는 사용자 한명이다.
  /// 채팅 관리자가 없으면 null을 반환한다.
  ///
  /// 채팅 관리자는 채팅방을 관리하는 사용자이다.
  /// RTDB 의 /admins 경로에 각 키는 관리자 UID 이고 값은 배열로 권한 목록을 가진다.
  /// 권한 목록에 'chat' 이 포함되어 있으면 채팅 관리자이다.
  String? get chatAdminUid {
    if (adminsValue.isEmpty) {
      return null;
    }
    for (String uid in admins) {
      if (adminsValue[uid] is List) {
        if ((adminsValue[uid] as List).contains('chat')) {
          return uid;
        }
      }
    }
    return null;
  }

  /// 사용자가 관리자인지 확인한다.
  ///
  /// 사용자가 관리자이면 true를 반환한다.
  bool checkAdmin(String uid) {
    return admins.contains(uid);
  }

  AdminService._() {
    dog('--> AdminService._()');
  }

  /// 관리자 서비스 초기화
  ///
  /// 관리자 목록을 가져와 메모리에 넣어 놓는다. 그리고 실시간 업데이트를 한다.
  init() {
    adminRef.onValue.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }

      adminsValue = Map<String, dynamic>.from(event.snapshot.value as Map);

      // print(admins);
      // print('chat admin uid: $chatAdminUid');

      isAdminStream.add(isAdmin);
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
