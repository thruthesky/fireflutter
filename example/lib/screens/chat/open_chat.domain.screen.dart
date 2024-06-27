import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class OpenChatDomainScreen extends StatefulWidget {
  static const String routeName = '/OpenChatDomain';
  const OpenChatDomainScreen({super.key});

  @override
  State<OpenChatDomainScreen> createState() => _OpenChatDomainScreenState();
}

class _OpenChatDomainScreenState extends State<OpenChatDomainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Chat'),
        actions: const [
          ChatRoomCreateButton(),
        ],
      ),
      body: ChatRoomListView(
        // openChat: true,
        chatRoomList: ChatRoomList.domain,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (room, index) => ChatRoomListTile(room: room),
      ),
    );
  }
}
