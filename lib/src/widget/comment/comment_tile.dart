import 'package:fireflutter/src/model/comment.dart';
import 'package:flutter/material.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    // get user

    return ListTile(
      // TODO Comment Tile
      title: Text('Title'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.content),
        ],
      ),
      onTap: () {
        // TODO actions
        // PostService.instance.showPostDialog(context, post);
      },
    );
  }
}
