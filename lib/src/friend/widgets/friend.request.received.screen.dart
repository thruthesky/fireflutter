import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/friend/widgets/friend.request.list_view.dart';
import 'package:flutter/material.dart';

class FriendRequestReceivedScreen extends StatelessWidget {
  const FriendRequestReceivedScreen({
    super.key,
    this.title,
  });

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? T.myReceivedFriendRequests.tr),
      ),
      body: FriendRequestListView(),
    );
  }
}
