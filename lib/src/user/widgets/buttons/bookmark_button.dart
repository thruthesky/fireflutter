import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BookmarkButton extends StatelessWidget {
  const BookmarkButton({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Value(
      // path: Bookmark.bookmarkUser(uid),
      ref: Bookmark.userRef(uid),
      builder: (v) => ElevatedButton(
        onPressed: () async {
          await Bookmark.toggle(context: context, otherUserUid: uid);
        },
        child: Text(
          v == null ? T.bookmark.tr : T.unbookmark.tr,
        ),
      ),
    );
  }
}
