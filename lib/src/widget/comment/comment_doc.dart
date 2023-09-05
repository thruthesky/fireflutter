import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentDoc extends StatelessWidget {
  const CommentDoc({super.key, required this.comment, required this.builder});

  final Comment comment;
  final Widget Function(Comment comment) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Comment.doc(comment.id).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (snapshot.hasData) return builder(Comment.fromDocumentSnapshot(snapshot.data!));
        return builder(comment);
      },
    );
  }
}
