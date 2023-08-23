import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/comment.dart';

import 'package:flutter/material.dart';

class CommentTileControlller extends ChangeNotifier {
  CommentTileState? state;

  showReplyBox() {
    state?._showReply = true;
    notifyListeners();
  }

  hideReplyBox() {
    state?._showReply = false;
    notifyListeners();
  }

  toggleReplyBox() {
    state?._showReply = !(state?._showReply ?? true);
    notifyListeners();
  }
}

class CommentTile extends StatefulWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.onTap,
    this.replyItemBuilder,
    this.onShowReplyBox,
    this.controller,
  });

  final Comment comment;
  final Function(Comment comment)? onTap;
  final Widget Function(BuildContext, Comment)? replyItemBuilder;
  final Function()? onShowReplyBox;
  final CommentTileControlller? controller;

  @override
  State<CommentTile> createState() => CommentTileState();
}

class CommentTileState extends State<CommentTile> {
  bool _showReply = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.state = this;
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO onLongPress
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 6.0),
              child: UserAvatar(
                uid: widget.comment.uid,
                key: ValueKey(widget.comment.id),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    UserDisplayName(
                      uid: widget.comment.uid,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), // TODO customization
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TimestampText(timestamp: widget.comment.createdAt),
                    ),
                  ],
                ),
                Text(widget.comment.content),
                Row(
                  children: [
                    TextButton(
                      child: const Text('Like'),
                      onPressed: () {},
                    ),
                    TextButton(
                      child: const Text('Reply'),
                      onPressed: () {
                        widget.onShowReplyBox?.call();
                        setState(() {
                          _showReply = !_showReply;
                        });
                      },
                    ),
                    // TODO make bottom action buttons customizer
                  ],
                ),
              ],
            )
          ],
        ),

        // TODO replyItemBuilder

        // TODO default comment tree

        Row(
          children: [
            SizedBox.fromSize(
              size: const Size(30, 0),
            ),
            Expanded(
              child: CommentListView(
                postId: widget.comment.postId,
                replyingTo: widget.comment.id,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                emptyBuilder: (context) {
                  return const SizedBox.shrink();
                },
                itemBuilder: widget.replyItemBuilder,
                onShowReplyBox: () {
                  // On show Reply
                  widget.onShowReplyBox?.call();
                },
              ),
            ),
          ],
        ),
        // TODO comment box here
        Visibility(
          visible: _showReply,
          child: Row(
            children: [
              SizedBox.fromSize(
                size: const Size(30, 0),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: CommentBox(
                    postId: widget.comment.postId,
                    replyTo: widget.comment.id,
                    labelText: 'Reply',
                    hintText: 'Write a reply...',
                    onSubmit: () {
                      setState(() {
                        _showReply = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
