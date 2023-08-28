import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/functions/comment_sort_string.dart';
import 'package:fireflutter/src/model/comment.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:fireflutter/src/service/comment.service.dart';
import 'package:fireflutter/src/types/last_comment_sort_by_depth.dart';
import 'package:flutter/material.dart';

class PostViewDialog extends StatefulWidget {
  const PostViewDialog({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<PostViewDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostViewDialog> {
  Map<int, String> lastSortPerDepth = {}; // TODO remove this
  LastChildCommentSort lastChildCommentSort = {};

  @override
  Widget build(BuildContext context) {
    late Post post;
    return StreamBuilder<DocumentSnapshot>(
      stream: PostService.instance.snapshot(postId: widget.post.id),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          post = widget.post;
        }
        if (snapshot.hasData) {
          post = Post.fromDocumentSnapshot(snapshot.data!);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Post'),
            actions: [
              if (widget.post.isMine)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    PostService.instance.showPostEditDialog(context, post: widget.post);
                  },
                ),
              PopupMenuButton(
                icon: const Icon(Icons.more_horiz),
                itemBuilder: (context) {
                  List<PopupMenuEntry<Object>> popupMenuItemList = [];
                  popupMenuItemList.add(
                    const PopupMenuItem(
                      value: "adjust_text_size",
                      child: Text("Adjust text size"),
                    ),
                  );
                  if (widget.post.isMine) {
                    popupMenuItemList.add(
                      const PopupMenuItem(
                        value: "delete_post",
                        child: Text("Delete"),
                      ),
                    );
                  }
                  return popupMenuItemList;
                },
                onSelected: (value) {
                  switch (value) {
                    case "adjust_text_size":
                      // TODO adjust Test size
                      // context.push('/adjust_text_size');
                      break;
                    case "delete_post":
                      // TODO delete post
                      debugPrint('deleting post');
                      break;
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Text.rich(
                    TextSpan(
                      text: post.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ), // TODO Customizable
                  ),
                ),
                if (widget.post.uid.isNotEmpty)
                  ListTile(
                    leading: UserAvatar(
                      uid: widget.post.uid,
                      key: ValueKey(widget.post.uid),
                    ),
                    title: UserDisplayName(
                      uid: widget.post.uid,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TimestampText(
                          timestamp: widget.post.createdAt, // TODO updated at
                        ),
                      ],
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(post.content),
                ),
                const Divider(),
                if (post.urls.isNotEmpty) ...post.urls.map((e) => DisplayMedia(url: e)).toList(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        child: const Text('Reply'),
                        onPressed: () async {
                          await CommentService.instance.showCommentBottomSheet(
                            context: context,
                            post: post,
                          );
                        },
                      ),
                      TextButton(
                        child: const Text('Like'),
                        onPressed: () {
                          debugPrint('Liking it');
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        child: const Text('Edit'),
                        onPressed: () {
                          PostService.instance.showPostEditDialog(context, post: post);
                        },
                      ),
                    ],
                  ),
                ),
                CommentListView(
                  post: post,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onShowReplyBox: (comment) {},
                  onCommentDisplay: (comment) {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
