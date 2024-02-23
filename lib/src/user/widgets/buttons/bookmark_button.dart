import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class BookmarkButton extends StatelessWidget {
  const BookmarkButton({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Value(
      path: Path.bookmarkUser(uid),
      builder: (v) => ElevatedButton(
        onPressed: () async {
          if (v != null) {
            await BookmarkModel.delete(otherUserUid: uid);
          } else {
            await BookmarkModel.create(otherUserUid: uid);
          }
        },
        child: Text(
          v == null ? T.bookmark.tr : T.bookmarked.tr,
        ),
      ),
    );
  }
}
