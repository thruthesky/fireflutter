import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/comment.dart';

import 'package:flutter/material.dart';

class CommentTileControlller extends ChangeNotifier {
  CommentTileState? state;

  showReplyBox() {
    state?.showReplyBox();
    notifyListeners();
  }

  hideReplyBox() {
    state?.hideReplyBox();
    notifyListeners();
  }

  toggleReplyBox() {
    state?.toggleReplyBox();
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
    this.onHideReplyBox,
    this.controller,
  });

  final Comment comment;
  final Function(Comment comment)? onTap;
  final Widget Function(BuildContext, Comment)? replyItemBuilder;
  final Function(Comment comment)? onShowReplyBox;
  final Function(Comment comment)? onHideReplyBox;
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
                        showReplyBox();
                      },
                    ),
                    // TODO make bottom action buttons customizer
                  ],
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  showReplyBox() {
    setState(() {
      _showReply = true;
    });
    widget.onShowReplyBox?.call(widget.comment);
  }

  hideReplyBox() {
    setState(() {
      _showReply = false;
    });
    widget.onHideReplyBox?.call(widget.comment);
  }

  toggleReplyBox() {
    _showReply = !_showReply;
    _showReply ? widget.onShowReplyBox?.call(widget.comment) : widget.onHideReplyBox?.call(widget.comment);
  }
}
