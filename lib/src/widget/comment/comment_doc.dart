import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentDoc extends StatelessWidget {
  const CommentDoc(
      {super.key, this.comment, this.commentId, required this.builder});

  final Comment? comment;
  final String? commentId;
  final Widget Function(Comment comment) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Comment.doc(comment?.id ?? commentId!).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (snapshot.hasData)
          return builder(Comment.fromDocumentSnapshot(snapshot.data!));
        if (comment != null) return builder(comment!);
        return const CircularProgressIndicator();
      },
    );
  }
}
