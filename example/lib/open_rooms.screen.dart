// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easychat/easychat.dart';
import 'package:flutter/material.dart';

class OpenRoomsScreen extends StatefulWidget {
  const OpenRoomsScreen({super.key});

  @override
  State<OpenRoomsScreen> createState() => _OpenRoomsScreen();
}

class _OpenRoomsScreen extends State<OpenRoomsScreen> {
  final displayName = TextEditingController();
  final photoUrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Open Rooms'),
      ),
      body: const ChatRoomOpenListView(),
    );
  }
}
