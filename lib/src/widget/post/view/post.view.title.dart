import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewTitle extends StatelessWidget {
  const PostViewTitle({
    super.key,
    this.post,
    this.padding = const EdgeInsets.only(
      left: sizeSm,
      right: sizeSm,
      top: sizeSm,
    ),
  });

  final Post? post;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        post?.title ?? '...',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
