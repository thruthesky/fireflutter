import 'dart:developer';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Favorite Icon
///
/// Use this to display if the user is favorited or not
class FavoriteIcon extends StatelessWidget {
  const FavoriteIcon({
    super.key,
    this.otherUid,
    this.postId,
    this.commentId,
    required this.builder,
    this.onChanged,
  }) : assert(otherUid != null || postId != null || commentId != null,
            "One of 'otherUid, postId, commentId' must have value");

  final String? otherUid;
  final String? postId;
  final String? commentId;
  final Widget Function(bool) builder;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Favorite.query(postId: postId, otherUid: otherUid, commentId: commentId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return builder(false);
        } else if (snapshot.hasError) {
          log(snapshot.error.toString());
          return builder(false);
        }

        return IconButton(
          onPressed: () async {
            final re = await Favorite.toggle(postId: postId, otherUid: otherUid, commentId: commentId);
            onChanged?.call(re);
          },
          icon: builder(snapshot.data?.size == 1),
        );
      },
    );
  }
}
