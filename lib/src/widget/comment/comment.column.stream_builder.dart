import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// This widget uses CacheService to prevent
/// the scroll problems for multiple nested
class CommentColumnStreamBuilder extends StatelessWidget {
  const CommentColumnStreamBuilder({
    super.key,
    required this.post,
    this.limit = 10,
    this.isCached = false,
    this.onCache,
    this.itemBuilder,
  });

  final Post post;
  final int limit;
  final bool isCached;
  final Function(String cacheId, QuerySnapshot snapshotData)? onCache;
  final Widget Function(BuildContext context, Comment comment, Post post)? itemBuilder;

  String get cacheId => 'post_comment_stream_${post.id}';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: isCached ? CacheService.instance.get(cacheId) as QuerySnapshot? : null,
      stream: commentCol
          .where('postId', isEqualTo: post.id)
          .orderBy('sort', descending: false)
          .limitToLast(limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          dog(snapshot.error.toString());
          return Text('Something went wrong; ${snapshot.error.toString()}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (!isCached && CacheService.instance.get(cacheId) != null) return const SizedBox.shrink();
        } else if (snapshot.hasData) {
          CacheService.instance.cache(cacheId, snapshot.data);
          onCache?.call(cacheId, snapshot.data!);
        } else {
          return const SizedBox.shrink();
        }
        final comments = snapshot.data?.docs.map((doc) => Comment.fromDocumentSnapshot(doc)).toList() ?? [];
        final children = comments
            .map((comment) =>
                itemBuilder?.call(context, comment, post) ??
                CommentOneLineListTile(
                  key: ValueKey(comment.id),
                  padding: const EdgeInsets.fromLTRB(0, sizeSm, sizeXxs, 0),
                  post: post,
                  comment: comment,
                ))
            .toList();
        return Column(children: children);
      },
    );
  }
}
