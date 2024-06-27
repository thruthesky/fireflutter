import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendService {
  static final instance = _instance ??= FriendService._();
  static FriendService? _instance;

  FriendService._();

  Future showFriendScreen({required BuildContext context}) {
    return showGeneralDialog(
        context: context,
        pageBuilder: ($, $$, $$$) => const FriendListScreen());
  }
}
