import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// PostViewScreen
///
/// This screen shows the details of a post.
///
/// [post] is coming from posts-summary node. Which means, it may not have the full data of the post.
///
/// [commentable] is a flag to show or hide the comment input field and the comments.
class PostViewScreen extends StatefulWidget {
  static const String routeName = '/PostView';
  const PostViewScreen({
    super.key,
    required this.post,
    this.commentable = true,
  });

  final Post post;
  final bool commentable;

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  Post get post => widget.post;
  int? previousNoOfLikes;

  /// [urls] is the URLs of the post photos.
  ///
  ///
  /// The [widget.post.urls] only contains the URL of the first photo from the post (as it's sourced from the posts-summary node).
  /// To display all photos in the PostViewScreen, we fetch the complete list of photo URLs from the database.
  final List<String> urls = [];

  /// [likes] is the list of uids that liked the posts
  /// This are mainly used for the [Icon] because the [widget.post.likes] are not working as expected
  /// This save and remove the [myUid] locally instead of reading from [widget.post.likes]
  final List<String> likes = [];
  @override
  void initState() {
    super.initState();

    if (post.urls.isNotEmpty) {
      urls.addAll(post.urls);
    }
    likes.addAll(post.likes);

    widget.post.urlsRef.once().then((DatabaseEvent event) {
      final value = event.snapshot.value as List<dynamic>?;

      if (value != null) {
        final List<String> data = List<String>.from(value);
        if (data.isNotEmpty) {
          urls.clear();
          urls.addAll(data);
          likes.clear();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(post.id);
    return Theme(
      data: Theme.of(context).copyWith(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelMedium,
            visualDensity: const VisualDensity(
              horizontal: -3,
              // vertical: -2,
            ),
          ),
        ),
      ),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              // title: PostMeta(
              //   post: post,
              //   avatarSize: 32,
              //   padding: const EdgeInsets.all(0),
              // ),
              centerTitle: false,
            ),
            SliverToBoxAdapter(child: PostMeta(post: post)),
            if (post.title != post.content)
              SliverToBoxAdapter(child: PostTitle(post: post)),
            SliverToBoxAdapter(child: PostContent(post: post)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Blocked(
                  otherUserUid: widget.post.uid,
                  yes: () => SizedBox.fromSize(),
                  no: () => DisplayDatabasePhotos(
                    initialData: widget.post.urls,
                    ref: widget.post.urlsRef,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                // to align the button from the comment list view
                padding: const EdgeInsets.only(left: 2.0, right: 16),
                child: Row(
                  children: [
                    TextButton.icon(
                      icon: likes.contains(myUid)
                          ? const Icon(Icons.thumb_up)
                          : const Icon(Icons.thumb_up_outlined),
                      iconAlignment: IconAlignment.start,
                      onPressed: () {
                        setState(() {
                          if (likes.contains(myUid)) {
                            likes.remove(myUid);
                          } else {
                            likes.add(myUid!);
                          }
                        });
                        post.like(context: context);
                      },
                      label: Login(
                        yes: (uid) => Value(
                          ref: post.noOfLikesRef,
                          builder: (no) {
                            previousNoOfLikes = no;
                            return Text('${T.like.tr}${likeText(no)}');
                          },
                          onLoading: Text(
                              '${T.like.tr}${likeText(previousNoOfLikes)}'),
                        ),
                        no: () => Text(T.like.tr),
                      ),
                    ),

                    /// Bookmark
                    TextButton.icon(
                      onPressed: () async {
                        await Bookmark.toggle(
                          context: context,
                          category: post.category,
                          postId: post.id,
                        );
                      },
                      label: Login(
                        yes: (uid) => Value(
                          ref: Bookmark.postRef(post.id),
                          builder: (v) => Text(
                            v == null ? T.bookmark.tr : T.unbookmark.tr,
                          ),
                        ),
                        no: () => Text(T.bookmark.tr),
                      ),
                      icon: Value(
                        ref: Bookmark.postRef(post.id),
                        builder: (v) => Icon(
                          v == null
                              ? Icons.bookmark_add_outlined
                              : Icons.bookmark_added,
                        ),
                      ),
                    ),

                    TextButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline_outlined),
                      onPressed: () => ChatService.instance.showChatRoomScreen(
                        context: context,
                        otherUid: post.uid,
                      ),
                      label: Text(T.chat.tr),
                    ),
                    // TextButton(
                    //   onPressed: () async {
                    //     final re = await input(
                    //       context: context,
                    //       title: T.reportInputTitle.tr,
                    //       subtitle: T.reportInputMessage.tr,
                    //       hintText: T.reportInputHint.tr,
                    //     );
                    //     if (re == null || re == '') return;
                    //     await Report.create(
                    //       postId: post.id,
                    //       category: post.category,
                    //       reason: re,
                    //     );
                    //   },
                    //   child: Text(T.report.tr),
                    // ),

                    // BlockButton.textButton(uid: post.uid),

                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton(
                          itemBuilder: (context) {
                            return [
                              if (post.uid == myUid) ...[
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text(T.edit.tr),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(T.delete.tr),
                                ),
                              ] else ...[
                                PopupMenuItem(
                                  value: 'block',
                                  child: Text(T.block.tr),
                                ),
                              ],
                              PopupMenuItem(
                                value: 'share',
                                child: Text(T.share.tr),
                              ),
                              PopupMenuItem(
                                value: 'report',
                                child: Text(T.report.tr),
                              ),
                            ];
                          },
                          onSelected: (value) async {
                            if (value == 'block') {
                              await UserService.instance.block(
                                context: context,
                                otherUserUid: post.uid,
                                ask: true,
                                notify: true,
                              );
                            } else if (value == 'share') {
                              final link =
                                  LinkService.instance.generatePostLink(post);
                              Share.shareUri(link);
                            } else if (value == 'edit') {
                              await ForumService.instance.showPostUpdateScreen(
                                  context: context, post: post);
                              await post.reload();
                              if (mounted) setState(() {});
                            } else if (value == 'delete') {
                              final re = await confirm(
                                context: context,
                                title: T.deletePostConfirmTitle.tr,
                                message: T.deletePostConfirmMessage.tr,
                              );
                              if (re != true) return;
                              await post.delete();
                              if (context.mounted) Navigator.of(context).pop();
                            } else if (value == 'report') {
                              final re = await input(
                                context: context,
                                title: T.reportInputTitle.tr,
                                subtitle: T.reportInputMessage.tr,
                                hintText: T.reportInputHint.tr,
                              );
                              if (re == null || re == '') return;
                              await Report.create(
                                postId: post.id,
                                category: post.category,
                                reason: re,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Show the label 'Comments' only if the post is commentable.
            if (widget.commentable)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(thickness: 1, height: 0),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, top: 12, bottom: 16),
                      child: Text(
                        T.comments.tr,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.commentable) CommentListView(post: post),
          ],
        ),
        bottomNavigationBar: widget.commentable
            ? SafeArea(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    /// 텍스트 입력 버튼 액션
                    await ForumService.instance.showCommentCreateScreen(
                      context: context,
                      post: post,
                      focusOnTextField: true,
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        /// 사진 버튼
                        IconButton(
                          onPressed: () async {
                            await ForumService.instance.showCommentCreateScreen(
                              context: context,
                              post: post,
                              showUploadDialog: true,
                            );
                          },
                          icon: const Icon(Icons.camera_alt),
                        ),
                        Expanded(child: Text(T.inputCommentHint.tr)),
                        const Icon(Icons.send),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox(
                height: 32), // Added because there is no space at the bottom
      ),
    );
  }
}
