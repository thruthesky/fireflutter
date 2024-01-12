import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class PostListTile extends StatelessWidget {
  const PostListTile({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(post.title),
      subtitle: Text(post.content),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => ForumService.instance.showPostViewScreen(
        context,
        post: post,
      ),
    );
  }
}
