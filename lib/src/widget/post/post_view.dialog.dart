import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: PostService.instance.snapshot(postId: widget.post.id),
      builder: (context, snapshot) {
        late Post post;
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

        // print('post.id: ${post.id}');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Post'),
            actions: [
              if (widget.post.isMine)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    PostService.instance.showEditDialog(context, post: widget.post);
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
                      // context.push('/adjust_text_size');
                      break;
                    case "delete_post":
                      debugPrint('deleting post');
                      break;
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: Text.rich(
                    TextSpan(
                      text: post.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
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
                          timestamp: widget.post.createdAt,
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
                          await CommentService.instance.showCommentEditBottomSheet(
                            context,
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
                      UserDoc(
                        live: true,
                        uid: post.uid,
                        builder: (user) {
                          debugPrint("Followers: ${user.followers}");
                          if (!user.followers.contains(my.uid)) {
                            return TextButton(
                              child: const Text('Follow'),
                              onPressed: () {
                                FeedService.instance.follow(post.uid);
                                tapSnackbar(
                                    context: context,
                                    title: 'Followed',
                                    message: 'You have followedthis user',
                                    onTap: (close) => close());
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        child: const Text('Edit'),
                        onPressed: () {
                          PostService.instance.showEditDialog(context, post: post);
                        },
                      ),
                    ],
                  ),
                ),
                CommentListView(
                  post: post,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
