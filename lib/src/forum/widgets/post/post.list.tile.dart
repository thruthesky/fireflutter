import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// [PostListTile] is a widget that displays the post title and its data.
///
/// It is a complete all-in-one widget that you can use for dispaly post list and content.
///
/// [children] is the list of widget that displays when user taps on the title.
///
class PostListTile extends StatelessWidget {
  const PostListTile({
    Key? key,
    required this.post,
    required this.children,
  }) : super(key: key);

  final Post post;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey(post.id),
      leading: post.files.isNotEmpty
          ? PostPreviewImage(
              url: post.files.first,
              size: 62,
            )
          : null,
      title: Text(
        post.deleted
            ? post.id.substring(0, 5)
            : post.displayTitle == ''
                ? "${post.subcategory.toUpperCase()} ..."
                : post.displayTitle,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: PostListMeta(post),
      ),
      trailing: Icon(
        post.open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
        color: Colors.grey,
      ),
      children: children,
      onExpansionChanged: (open) => post.open = open,
      initiallyExpanded: post.open,
    );
  }
}
