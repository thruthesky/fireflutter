import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/friend/widgets/friend.request.received.screen.dart';
import 'package:fireflutter/src/friend/widgets/friend.request.sent.screen.dart';
import 'package:flutter/material.dart';

class FriendService {
  static final instance = _instance ??= FriendService._();
  static FriendService? _instance;

  FriendService._();

  Future<void> showFriendScreen({
    required BuildContext context,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => const FriendListScreen(),
    );
  }

  Future<void> showReceivedRequestScreen({
    required BuildContext context,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => const FriendRequestReceivedScreen(),
    );
  }

  Future<void> showSentRequestScreen({
    required BuildContext context,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => const FriendRequesetSentScreen(),
    );
  }
}
