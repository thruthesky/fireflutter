import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';

class AdminCommentListScreen extends StatefulWidget {
  static const String routeName = '/AdminCommentList';
  const AdminCommentListScreen({super.key});

  @override
  State<AdminCommentListScreen> createState() => _AdminCommentListScreenState();
}

class _AdminCommentListScreenState extends State<AdminCommentListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Text('Admin Comment List', style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface)),
      ),
      body: FirestoreListView(
        query: Comment.col.orderBy('createdAt', descending: true),
        itemBuilder: (context, snapshot) {
          final comment = Comment.fromDocumentSnapshot(snapshot);
          return ListTile(
            title: Text(comment.content),
            subtitle: Text(comment.uid),
            trailing: Text(comment.createdAt.toString()),
          );
        },
      ),
    );
  }
}
