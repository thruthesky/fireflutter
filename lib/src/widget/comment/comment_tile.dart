import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/comment.dart';
import 'package:flutter/material.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.onTap,
  });

  final Comment comment;
  final Function(Comment comment)? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 6.0),
                child: UserAvatar(
                  uid: comment.uid,
                  key: ValueKey(comment.id),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      UserDisplayName(
                        uid: comment.uid,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), // TODO customization
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TimestampText(timestamp: comment.createdAt),
                      ),
                    ],
                  ),
                  Text(comment.content),
                  Row(
                    children: [
                      TextButton(
                        child: const Text('Like'),
                        onPressed: () {},
                      ),
                      TextButton(
                        child: const Text('Reply'),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
          // TODO should we put the action buttons here?
        ],
      ),
    );
  }
}
