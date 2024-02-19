import 'dart:async';

import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// A list of comments for a post
///
/// To lessen the screen flickering (and the number of reads), we do the followings.
/// 1. get all the comments
/// 2. listen each comments for update
/// 3. listen new comments.
class CommentListView extends StatefulWidget {
  const CommentListView({super.key, required this.post});

  final PostModel post;

  @override
  State<CommentListView> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  List<CommentModel>? comments;
  StreamSubscription? newCommentSubscription;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    // await get(Path.comments(widget.post.id));

    comments = await CommentModel.getAll(postId: widget.post.id);
    setState(() {});

    // Generate a flutter code with firebase realtime database that listens to newly created data on the path 'comments/${widget.post.id}'
    newCommentSubscription = widget.post.commentsRef
        .limitToLast(1)
        .orderByChild('order')
        .onChildAdded
        .listen((event) {
      final comment = CommentModel.fromSnapshot(event.snapshot);

      final int index =
          comments!.indexWhere((element) => element.id == comment.id);

      /// Exisiting comment. Do nothing. This happens on the first time.
      if (index > -1) {
        return;
      }

      comments?.add(comment);
      comments = CommentModel.sortComments(comments!); // sort the comments

      /// This may trigger the screen flickering. It's okay. It's a rear case.
      setState(() {});
    });
  }

  @override
  void dispose() {
    newCommentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (comments == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (comments!.isEmpty) {
      return const Center(child: Text('No comments'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments!.length,
      itemBuilder: (context, index) {
        final comment = comments![index];
        return CommentView(
          post: widget.post,
          comment: comment,
        );
      },
    );
  }
}
