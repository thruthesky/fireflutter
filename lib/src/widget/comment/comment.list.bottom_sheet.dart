import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Comment List Bottom Sheet
///
/// This widget shows the comment list of the post in a bottom sheet UI style.
/// Use this widget with [showModalBottomSheet].
class CommentListBottomSheet extends StatelessWidget {
  const CommentListBottomSheet({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      // margin: const EdgeInsets.symmetric(horizontal: sizeSm),
      child: Column(
        children: [
          // in testing mode we need to use this container to test the widget to be dragged to close
          // since we uses the showDraghandle on showmodalbottomsheet on theme instead of custom notch or draghandle
          // i can't find a way to give it a key or something to test it. so this container is the solution
          // i came up with.
          Container(
            height: 4,
            key: const Key('CommentListBottomSheet'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent,
            ),
          ),
          Expanded(
            child: CommentOneLineListView(post: post),
          )
        ],
      ),
    );
  }
}
