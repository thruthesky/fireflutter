import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/friend/widgets/friend.request.received.screen.dart';
import 'package:fireflutter/src/friend/widgets/friend.request.sent.screen.dart';
import 'package:flutter/material.dart';

class FriendService {
  static final instance = _instance ??= FriendService._();
  static FriendService? _instance;

  FriendService._();

  /// Shows Friend List Screen
  ///
  Future<void> showListScreen({
    required BuildContext context,
    String? uid,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => FriendListScreen(
        uid: uid,
      ),
    );
  }

  Future<void> showReceivedListScreen({
    required BuildContext context,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => const FriendRequestReceivedScreen(),
    );
  }

  Future<void> showSentListScreen({
    required BuildContext context,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => const FriendRequesetSentScreen(),
    );
  }
}
