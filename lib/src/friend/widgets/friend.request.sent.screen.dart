import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/friend/widgets/friend.request.list_view.dart';
import 'package:flutter/material.dart';

class FriendRequesetSentScreen extends StatelessWidget {
  const FriendRequesetSentScreen({
    super.key,
    this.title,
  });

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? T.mySentFriendRequests.tr),
      ),
      body: FriendRequestListView(
        list: FriendRequestList.sent,
      ),
    );
  }
}
