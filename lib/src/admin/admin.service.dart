import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminService {
  static AdminService? _instance;
  static AdminService get instance => _instance ??= AdminService._();

  AdminService._() {
    dog('--> AdminService._()');
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
