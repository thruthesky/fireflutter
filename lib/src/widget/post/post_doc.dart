import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostDoc extends StatelessWidget {
  const PostDoc({
    super.key,
    required this.postId,
    this.post,
    required this.builder,
  });

  final String postId;
  final Post? post;
  final Widget Function(Post post) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Post.doc(postId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (snapshot.hasData) return builder(Post.fromDocumentSnapshot(snapshot.data!));
        return post != null ? builder(post!) : const Center(child: CircularProgressIndicator());
      },
    );
  }
}
