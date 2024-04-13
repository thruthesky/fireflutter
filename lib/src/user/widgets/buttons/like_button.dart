import 'dart:async';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Like button
///
/// When A likes B, the B's noOfLikes will increase by 1. But the noOfLikes may
/// not updated immedately. This is because the B's noOfLikes is updated in the
/// cloud function(Not in the frontend). And sometimes, it becomes slow. So,
/// this widget computes the noOfLikes in the frontend and update it quickly.
class LikeButton extends StatefulWidget {
  const LikeButton({super.key, this.uid, this.user});

  final String? uid;
  final User? user;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  String get userUid => widget.uid ?? widget.user!.uid;
  int noOfLikes = 0;

  StreamSubscription? unlisten;

  @override
  void initState() {
    super.initState();

    noOfLikes = widget.user?.noOfLikes ?? 0;

    unlisten = User.userRef(userUid).child(Field.noOfLikes).onValue.listen((v) {
      setState(
        () => noOfLikes = int.tryParse(v.snapshot.value.toString()) ?? 0,
      );
    });
  }

  @override
  void dispose() {
    unlisten?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final re = await UserService.instance.like(
          context: context,
          otherUserUid: userUid,
        );

        if (re == true) {
          setState(() => noOfLikes++);
        } else if (re == false) {
          setState(() => noOfLikes--);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            noOfLikes <= 1 ? T.like.tr : T.likes.tr,
          ),
          noOfLikes > 0 ? Text(' $noOfLikes') : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
