import 'dart:async';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// A list of comments for a post
///
/// To lessen the screen flickering (and the number of reads), we do the followings.
/// 1. get all the comments
/// 2. listen each comments for update
/// 3. listen new comments.
class CommentListView extends StatefulWidget {
  const CommentListView({super.key, required this.post});

  final Post post;

  @override
  State<CommentListView> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  List<Comment>? comments;
  StreamSubscription? newCommentSubscription;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    // Getting all the comments first
    comments = await Comment.getAll(postId: widget.post.id);

    setState(() {});

    // print('path: ${widget.post.commentsRef.path}');

    // Generate a flutter code with firebase realtime database that listens
    // to newly created data on the path 'comments/${widget.post.id}'
    newCommentSubscription = widget.post.commentsRef
        .limitToLast(1)
        .orderByChild('order')
        .onChildAdded
        .listen(
      (event) {
        final comment = Comment.fromJson(
          event.snapshot.value as Map,
          event.snapshot.key!,
          postId: widget.post.id,
        );
        // Check if the comment is already in the list.
        final int index =
            comments!.indexWhere((element) => element.id == comment.id);
        // Exisiting comment. Do nothing. This happens on the first time.
        if (index > -1) return;
        // Add the comment to the list
        comments?.add(comment);
        // Sort the comments
        comments = Comment.sortComments(comments!);
        // This may trigger the screen flickering. It's okay. It's a rare case.
        setState(() {});
      },
      onError: (error) {
        dog('----> CommentListView::initState() -> init() listen new comment: $error, path: ${widget.post.commentsRef.path}');
        throw error;
      },
    );
  }

  @override
  void dispose() {
    newCommentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (comments == null) {
      return const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()));
    }
    if (comments!.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(T.commentEmptyList.tr),
          ),
        ),
      );
    }
    // on going work for collapsible comments
    // return SliverToBoxAdapter(
    //   child: ExpansionPanelList(
    //     children: parentComments!
    //         .map(
    //           (comment) => ExpansionPanel(
    //             headerBuilder: (context, expanded) =>
    //                 CommentView(post: widget.post, comment: comment),
    //             body: const Column(),
    //           ),
    //         )
    //         .toList(),
    //   ),
    // );

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final comment = comments![index];
          return CommentView(
            post: widget.post,
            comment: comment,
          );
        },
        childCount: comments!.length,
      ),
    );
    // return SliverToBoxAdapter(
    //   child: NewCommentView(
    //     comments: comments!,
    //     post: widget.post,
    //   ),
    // );
  }
}
