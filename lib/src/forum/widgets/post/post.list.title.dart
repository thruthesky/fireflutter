import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostListTitle extends StatelessWidget {
  const PostListTitle({super.key, required this.post, required this.onTap});

  final PostModel post;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(post.displayTitle),
      subtitle: UserDoc(
        uid: post.uid,
        builder: (user) {
          return Text(user.displayName);
        },
      ),
      onTap: onTap,
    );
  }
}
