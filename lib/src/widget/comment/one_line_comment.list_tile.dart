import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// A widget that display comment in one line.
///
///
class OnlineComment extends StatelessWidget {
  const OnlineComment({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            UserAvatar(uid: comment.uid, radius: 20, size: 40),
            const SizedBox(width: sizeXs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserDoc(
                  uid: comment.uid,
                  builder: (user) => Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Row(
                  children: [
                    DateTimeText(
                      dateTime: comment.createdAt,
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Text(comment.content),
      ],
    );
  }
}
