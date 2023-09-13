import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewTitle extends StatelessWidget {
  const PostViewTitle({
    super.key,
    this.post,
  });

  final Post? post;

  @override
  Widget build(BuildContext context) {
    return Text(post?.title ?? '...');
  }
}
