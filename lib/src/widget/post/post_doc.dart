import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostDoc extends StatelessWidget {
  const PostDoc({
    super.key,
    this.post,
    this.postId,
    this.live = true,
    required this.builder,
    this.onLoading,
  });

  final Post? post;
  final String? postId;
  final bool live;
  final Widget Function(Post post) builder;
  final Widget? onLoading;

  String get id => post?.id ?? postId!;

  @override
  Widget build(BuildContext context) {
    if (live) {
      return StreamBuilder<DocumentSnapshot>(
        stream: Post.doc(id).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return onLoading ??
                const Center(
                  child: CircularProgressIndicator(),
                );
          }
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (snapshot.hasData) {
            return builder(Post.fromDocumentSnapshot(snapshot.data!));
          }
          if (post != null) return builder(post!);
          return const SizedBox.shrink();
        },
      );
    }
    return FutureBuilder<Post?>(
      future: Post.get(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return onLoading ??
              const Center(
                child: CircularProgressIndicator(),
              );
        }
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (snapshot.hasData) return builder(snapshot.data!);
        if (post != null) return builder(post!);
        return const SizedBox.shrink();
      },
    );
  }
}
