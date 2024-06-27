import 'package:fireflutter/src/friend/widgets/friend.request.list_view.dart';
import 'package:flutter/material.dart';

class FriendRequestReceivedScreen extends StatelessWidget {
  const FriendRequestReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Request Received'),
      ),
      body: FriendRequestListView(),
    );
  }
}
