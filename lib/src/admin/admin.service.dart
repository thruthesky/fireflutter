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
}
