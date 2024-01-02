import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';
import 'package:fireship/fireship.test.functions.dart';
import 'package:flutter/material.dart';

class AdminDashBoardScreen extends StatefulWidget {
  const AdminDashBoardScreen({super.key});

  @override
  State<AdminDashBoardScreen> createState() => _AdminDashBoardScreenState();
}

class _AdminDashBoardScreenState extends State<AdminDashBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin DashBoard'),
      ),
      body: Column(
        children: [
          const Text('Chat'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () async {
                  for (int i = 0; i < 10; i++) {
                    final user = await loginOrRegister(
                      email: 'test$i@email.com',
                      password: '12345a',
                      photoUrl: 'https://picsum.photos/id/${i * 100}/300/300',
                    );

                    ChatModel chat = ChatModel(room: ChatRoomModel.fromRoomdId('all'));
                    await chat.join();
                    await chat.sendMessage(
                      text: '테스트 메시지 from ${user.email}',
                    );
                  }
                },
                child: const Text('테스트 사용자로 로그인해서 전체 채팅방에 채팅하기'),
              ),
              ElevatedButton(
                onPressed: () async {
                  for (int i = 0; i < 10; i++) {
                    final user = await loginOrRegister(
                      email: 'test$i@email.com',
                      password: '12345a',
                      photoUrl: 'https://picsum.photos/id/${i * 100}/300/300',
                    );

                    ChatModel chat = ChatModel(room: ChatRoomModel.fromRoomdId('all'));
                    final ref = ChatService.instance.messageRef(roomId: 'all');
                    final snapshot = await ref.orderByChild('uid').equalTo(user.uid).get();
                    if (snapshot.value != null) {
                      final nodes = snapshot.value as Map<dynamic, dynamic>;
                      for (final node in nodes.entries) {
                        await ref.child(node.key).remove();
                      }
                    }
                    await chat.leave();
                  }
                },
                child: const Text('테스트 사용자로 로그인해서 전체 채팅방에 채팅 삭제하기'),
              ),
              ElevatedButton(
                onPressed: () {
                  AdminService.instance.showUserList(context: context);
                },
                child: const Text('전체 사용자 목록'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('신고목록'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
