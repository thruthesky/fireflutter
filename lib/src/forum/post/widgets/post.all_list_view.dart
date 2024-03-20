import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 전체 글 목록
///
/// /post-all-summaries 경로에 있는 모든 카테고리의 글 목록을 보여주는 위젯
///
///
class PostAllListView extends StatelessWidget {
  const PostAllListView({
    super.key,
    required this.itemBuilder,
  });

  final Widget Function(Post) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: Post.postAllSummariesRef.orderByChild(Field.order),
      itemBuilder: (context, snapshot) {
        final post = Post.fromSnapshot(snapshot);
        if (post.deleted) {
          return const SizedBox.shrink();
        }
        return itemBuilder(post);
      },
    );
  }
}
