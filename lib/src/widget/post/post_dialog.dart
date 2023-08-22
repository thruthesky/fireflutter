import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:flutter/material.dart';

class PostDialog extends StatefulWidget {
  const PostDialog({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  TextEditingController postName = TextEditingController();
  TextEditingController description = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text.rich(
                TextSpan(
                  text: widget.post.title,
                  style: const TextStyle(fontSize: 18),
                ), // TODO Customizable
              ),
            ),
            if (widget.post.uid.isNotEmpty)
              ListTile(
                leading: UserAvatar(
                  uid: widget.post.uid,
                  key: ValueKey(widget.post.uid),
                ),
                title: UserDisplayName(
                  uid: widget.post.uid,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.post.createdAt.toDate()}'),
                  ],
                ),
              ),
            Padding(padding: const EdgeInsets.all(16.0), child: Text(widget.post.content)),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  child: const Text('Like'),
                  onPressed: () {
                    debugPrint('Liking it');
                  },
                ),
              ],
            ),
            ListView(
              // TODO Comment list view
              shrinkWrap: true,
            ),
            CommentBox(
              post: widget.post,
            ),
          ],
        ),
      ),
    );
  }
}
