import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewersScreen extends StatelessWidget {
  const PostViewersScreen({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewers'),
      ),
      body: FirestoreListView(
        query: PostService.instance.noOfPostViewCol,
        itemBuilder: (context, QueryDocumentSnapshot snapshot) {
          // final viewer = snapshot.data[];
          return UserDoc(
              // uid: viewer,
              builder: (user) {
            return Text('Viewer Ongoing');
          });
        },
      ),
    );
  }
}
