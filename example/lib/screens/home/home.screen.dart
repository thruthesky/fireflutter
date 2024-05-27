import 'package:example/screens/chat/chat.screen.dart';
import 'package:example/screens/chat/open_chat.screen.dart';
import 'package:example/screens/entry/entry.screen.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          const Text("Home"),
          Login(
            yes: (uid) {
              return Column(
                children: [
                  const Text("@TODO: 채팅방 방장이, 채팅 삭제, 채팅방 멤버 강퇴 기능 추가"),
                  Text("Logged in as $uid"),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                          onPressed: () => UserService.instance
                              .showProfileUpdateScreen(context: context),
                          child: const Text('Profile Update')),
                      ElevatedButton(
                        onPressed: () async {
                          await UserService.instance.signOut();
                          if (context.mounted) {
                            context.go(EntryScreen.routeName);
                          }
                        },
                        child: const Text('Sign Out'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push(ChatScreen.routeName),
                        child: const Text('Chat'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push(OpenChatScreen.routeName),
                        child: const Text('Open Chat'),
                      ),
                    ],
                  ),
                ],
              );
            },
            no: () => const Text("Not logged in"),
          ),
          const Expanded(child: UserListView())
        ],
      ),
    );
  }
}
