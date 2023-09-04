import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewDialog extends StatefulWidget {
  const PostViewDialog({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<PostViewDialog> createState() => _PostViewDialogState();
}

class _PostViewDialogState extends State<PostViewDialog> {
  late Post post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  onEdit() async {
    final updated = await PostService.instance.showEditDialog(context, post: post);
    if (updated != null) {
      setState(() {
        post = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          if (post.isMine) IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
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
              if (post.isMine) {
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
            if (post.uid.isNotEmpty)
              ListTile(
                leading: UserAvatar(
                  uid: post.uid,
                  key: ValueKey(post.uid),
                ),
                title: UserDisplayName(
                  uid: post.uid,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateTimeText(
                      dateTime: post.createdAt,
                      type: DateTimeTextType.short,
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
                  PostDoc(
                    post: post,
                    builder: (post) => TextButton(
                      child: Text(
                        'Like ${post.noOfLikes}',
                        style: post.iLiked ? const TextStyle(fontWeight: FontWeight.bold) : null,
                      ),
                      onPressed: () => post.likeOrUnlike(),
                    ),
                  ),
                  UserDoc(
                    live: true,
                    builder: (user) => TextButton(
                        onPressed: () async {
                          final re = await FeedService.instance.follow(post.uid);
                          toast(
                            title: re ? 'Followed' : 'Unfollowed',
                            message: re ? 'You have followed this user' : 'You have unfollowed this user',
                          );
                        },
                        child: Text(user.followings.contains(post.uid) ? 'Unfollow' : 'Follow')),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onEdit,
                    child: const Text('Edit'),
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
  }
}
