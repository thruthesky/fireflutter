import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostListMeta extends StatelessWidget {
  const PostListMeta(this.post, {Key? key}) : super(key: key);

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // User(uid: post.uid, size: 20, iconSize: 16),
            UserDoc(uid: post.uid, builder: (user) => ProfilePhoto(user: user)),
            UserName(
              uid: post.uid,
              padding: EdgeInsets.only(left: 8),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            ShortDate(
              toInt(post.createdAt!.millisecondsSinceEpoch / 1000),
              style: TextStyle(fontSize: 12, color: Colors.grey),
              padding: EdgeInsets.only(left: 8),
            ),
          ],
        ),
      ],
    );
  }
}
