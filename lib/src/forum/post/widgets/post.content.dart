import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// PostContent
///
/// Display the content of a post.
class PostContent extends StatefulWidget {
  const PostContent({super.key, required this.post});

  final PostModel post;

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  /// 내용을 캐시해서, 깜빡이지 않도록 한다.
  String content = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: widget.post.onFieldChange(
        Field.content,
        (v) {
          content = v ?? '';
          return _text();
        },
        onLoading: _text(),
      ),
    );
  }

  _text() {
    return Text(content.orBlocked(widget.post.uid, T.blockedContentMessage));
  }
}
