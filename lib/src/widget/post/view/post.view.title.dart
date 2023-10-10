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
    this.contentBackground,
  });

  final Post? post;
  final EdgeInsetsGeometry padding;
  final Color? contentBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: contentBackground,
      child: Text(post != null ? post!.title.replaceAll("\n", " ") : '',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
