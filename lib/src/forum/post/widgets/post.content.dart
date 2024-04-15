import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// PostContent
///
/// Display the content of a post.
class PostContent extends StatefulWidget {
  const PostContent({super.key, required this.post});

  final Post post;

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
    /// 차단이 되었으면, 차단 메시지를 보여준다.
    return Blocked(
      otherUserUid: widget.post.uid,
      no: () => Text(content),
      yes: () => const Text(T.blockedContentMessage),
    );
  }
}
