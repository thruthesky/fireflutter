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
        title: const Text('My sent requests'),
      ),
      body: const Column(
        children: [
          Text("WhoIRequestedTo"),
        ],
      ),
    );
  }
}
