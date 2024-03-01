import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostListView extends StatelessWidget {
  const PostListView({super.key, required this.category});

  final String category;
  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: Ref.postSummaries.child(category).orderByChild(Field.order),
      itemBuilder: (context, snapshot) {
        final post = PostModel.fromSnapshot(snapshot);
        if (post.deleted) {
          return const SizedBox.shrink();
        }
        return PostListTile(
          post: post,
        );
      },
    );
  }
}
