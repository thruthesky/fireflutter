import 'dart:async';

import 'package:easychat/easychat.dart';
import 'package:example/chat.screen.dart';
import 'package:example/example.chat.room.screen.dart';
import 'package:example/open_rooms.screen.dart';
import 'package:example/profile.screen.dart';
import 'package:example/user.list.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void initState() {
    super.initState();

    Timer.run(() {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));

      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserListScren()));

// // How to test a chat room screen:
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           /// Open the chat room screen with a chat room for the UI work and testing.
//           builder: (_) => ExampleChatRoomScreen(
//             /// Get the chat room from the firestore and pass it to the screen for the test.
//             room: ChatRoomModel.fromMap(
//               id: 'mFpHRSZLCemCfC2B9Y3B',
//               map: {
//                 'name': 'Test Chat Room',
//               },
//             ),
//           ),
//         ),
//       );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;

                return user == null
                    ? Column(
                        children: [
                          const Text("Login required to use EasyChat"),
                          const SizedBox(height: 16),
                          TextField(
                            controller: email,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: password,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          Row(children: [
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(email: email.text, password: password.text);
                              },
                              child: const Text('Login'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(email: email.text, password: password.text);
                              },
                              child: const Text('Register'),
                            ),
                          ]),
                        ],
                      )
                    : Column(
                        children: [
                          Text("You are logged in with: ${user.uid}, ${user.email}"),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => FirebaseAuth.instance.signOut(),
                            child: const Text('Logout'),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
                            },
                            child: const Text('Open EasyChat Room List'),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserListScren()));
                            },
                            child: const Text('Open User List'),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  /// Open the chat room screen with a chat room for the UI work and testing.
                                  builder: (_) => ExampleChatRoomScreen(
                                    /// Get the chat room from the firestore and pass it to the screen for the test.
                                    room: ChatRoomModel.fromMap(
                                      id: 'mFpHRSZLCemCfC2B9Y3B',
                                      map: {
                                        'name': 'Test Chat Room',
                                        'group': true,
                                        'open': false,
                                        'users': [],
                                        'master': '',
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Open Example Chat Room'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                            child: const Text('Profile'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OpenRoomsScreen())),
                            child: const Text('Join Open Rooms'),
                          ),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
