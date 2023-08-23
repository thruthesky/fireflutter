import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:flutter/material.dart';

class PostDialog extends StatefulWidget {
  const PostDialog({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  Post? post;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: PostService.instance.snapshot(postId: widget.post.id),
        builder: (context, postSnapshot) {
          // error
          if (postSnapshot.hasError) {
            return Text(postSnapshot.error.toString());
          }
          if (postSnapshot.hasData) {
            post = Post.fromDocumentSnapshot(postSnapshot.data!);
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Post'),
              actions: [
                if (PostService.instance.isMine(widget.post))
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      PostService.instance.showEditPostDialog(context, widget.post);
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
                    if (PostService.instance.isMine(widget.post)) {
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
                // IconButton(
                //   icon: const Icon(Icons.more_horiz),
                //   onPressed: () {},
                // )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Text.rich(
                            TextSpan(
                              text: post?.title ?? '',
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
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Text(post?.content ?? ''),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton(
                                child: const Text('Like'),
                                onPressed: () {
                                  debugPrint('Liking it');
                                },
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                          child: Text(
                            "Comments",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        CommentListView(
                          postId: widget.post.id,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: CommentBox(
                        post: widget.post,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
