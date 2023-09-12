import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewScreen extends StatefulWidget {
  const PostViewScreen({
    super.key,
    this.post,
    this.postId,
  });

  final Post? post;
  final String? postId;

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  Post? _post;
  get post => _post!;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _post = widget.post;
    } else {
      (() async {
        _post = await PostService.instance.get(widget.postId!);
        setState(() {});
      })();
    }
  }

  onEdit() async {
    final updated =
        await PostService.instance.showEditDialog(context, post: post);
    if (updated != null) {
      setState(() {
        _post = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          if (post.isMine)
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
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
      body: _post == null
          ? const CircularProgressIndicator.adaptive()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 16.0),
                    child: Text.rich(
                      TextSpan(
                        text: post.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  // user avatar
                  Row(
                    children: [
                      UserAvatar(
                        uid: post.uid,
                        key: ValueKey(post.uid),
                        onTap: () => UserService.instance
                            .showPublicProfileScreen(
                                context: context, uid: post.uid),
                      ),
                      UserDisplayName(
                        uid: post.uid,
                      ),
                      DateTimeText(
                        dateTime: post.createdAt,
                        type: DateTimeTextType.short,
                      ),
                    ],
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
                  YouTube(url: post.youtubeId, autoPlay: true),
                  const Divider(),
                  if (post.urls.isNotEmpty)
                    ...post.urls.map((e) => DisplayMedia(url: e)).toList(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          child: const Text('Reply'),
                          onPressed: () async {
                            await CommentService.instance
                                .showCommentEditBottomSheet(
                              context,
                              post: post,
                            );
                          },
                        ),
                        PostDoc(
                          postId: post.id,
                          post: post,
                          builder: (post) => TextButton(
                            child: Text(
                              'Like ${post.noOfLikes}',
                              style: post.iLiked
                                  ? const TextStyle(fontWeight: FontWeight.bold)
                                  : null,
                            ),
                            onPressed: () => post.like(),
                          ),
                        ),
                        UserDoc(
                          live: true,
                          builder: (user) => TextButton(
                            onPressed: () async {
                              final re =
                                  await FeedService.instance.follow(post.uid);
                              toast(
                                title: re ? 'Followed' : 'Unfollowed',
                                message: re
                                    ? 'You have followed this user'
                                    : 'You have unfollowed this user',
                              );
                            },
                            child: Text(user.followings.contains(post.uid)
                                ? 'Unfollow'
                                : 'Follow'),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ReportService.instance.showReportDialog(
                              context: context,
                              postId: post.id,
                              onExists: (id, type) => toast(
                                  title: 'Already reported',
                                  message:
                                      'You have reported this $type already.'),
                            );
                          },
                          child: const Text('Report'),
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
