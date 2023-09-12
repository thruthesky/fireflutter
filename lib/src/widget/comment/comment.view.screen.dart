import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Dispaly a comment in a screen
///
/// Display a button to open the origin post screen.
class CommentViewScreen extends StatefulWidget {
  static const String routeName = '/CommentView';
  const CommentViewScreen({
    super.key,
    this.comment,
    this.commentId,
  });

  final Comment? comment;
  final String? commentId;

  @override
  State<CommentViewScreen> createState() => _CommentViewScreenState();
}

class _CommentViewScreenState extends State<CommentViewScreen> {
  Comment? comment;

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) {
      comment = widget.comment;
    } else {
      (() async {
        comment = await Comment.get(widget.commentId!);
        setState(() {});
      })();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CommentView'),
      ),
      body: comment == null
          ? const CircularProgressIndicator.adaptive()
          : Column(
              children: [
                Text(comment!.content),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          PostService.instance.showPostViewScreen(
                              context: context, postId: comment!.postId);
                        },
                        child: const Text('Open post')),
                  ],
                )
              ],
            ),
    );
  }
}
