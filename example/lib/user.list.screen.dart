import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easychat/easychat.dart';
import 'package:example/chat.screen.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

class UserListScren extends StatefulWidget {
  const UserListScren({super.key});

  @override
  State<UserListScren> createState() => _UserListScrenState();
}

class _UserListScrenState extends State<UserListScren> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('User List'),
      ),
      body: FirestoreListView(
        query: FirebaseFirestore.instance.collection('users'),
        itemBuilder: (context, snapshot) {
          final user = UserModel.fromDocumentSnapshot(snapshot);
          return ListTile(
            title: Text(user.displayName),
            subtitle: Text(user.uid),
            leading: user.photoUrl.isEmpty
                ? null
                : CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  user: user,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
