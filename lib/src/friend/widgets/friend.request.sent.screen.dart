import 'package:fireflutter/src/friend/widgets/friend.request.list_view.dart';
import 'package:flutter/material.dart';

class FriendRequesetSentScreen extends StatefulWidget {
  const FriendRequesetSentScreen({super.key});

  @override
  State<FriendRequesetSentScreen> createState() =>
      _FriendRequesetSentScreenState();
}

class _FriendRequesetSentScreenState extends State<FriendRequesetSentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sent Requests'),
      ),
      body: FriendRequestListView(
        list: FriendRequestList.sent,
      ),
    );
  }
}
