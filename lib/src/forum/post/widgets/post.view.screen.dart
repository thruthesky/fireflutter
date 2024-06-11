import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/common/photo_view/photo.view.screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// PostViewScreen
///
/// This screen shows the details of a post.
///
/// [post] is coming from posts-summary node. Which means, it may not have the full data of the post.
class PostViewScreen extends StatefulWidget {
  static const String routeName = '/PostView';
  const PostViewScreen({super.key, required this.post});

  final Post post;

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

  @override
  void initState() {
    super.initState();

    if (post.urls.isNotEmpty) {
      urls.addAll(post.urls);
    }

    widget.post.urlsRef.once().then((DatabaseEvent event) {
      final value = event.snapshot.value as List<dynamic>?;

      if (value != null) {
        final List<String> data = List<String>.from(value);
        if (data.isNotEmpty) {
          urls.clear();
          urls.addAll(data);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              title: PostTitle(post: post),
            ),
            SliverToBoxAdapter(child: PostMeta(post: post)),
            SliverToBoxAdapter(child: PostContent(post: post)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Blocked(
                  otherUserUid: widget.post.uid,
                  yes: () => SizedBox.fromSize(),
                  no: () => GestureDetector(
                    onTap: () {
                      dog(urls.length.toString());
                      showGeneralDialog(
                        context: context,
                        pageBuilder: (_, __, ___) => PhotoViewerScreen(
                          urls: urls,
                        ),
                      );
                    },
                    child: DisplayDatabasePhotos(
                      initialData: widget.post.urls,
                      ref: widget.post.urlsRef,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => post.like(context: context),
                    child: Login(
                      yes: (uid) => Value(
                        ref: post.noOfLikesRef,
                        builder: (no) {
                          previousNoOfLikes = no;
                          return Text('${T.like.tr}${likeText(no)}');
                        },
                        onLoading:
                            Text('${T.like.tr}${likeText(previousNoOfLikes)}'),
                      ),
                      no: () => Text(T.like.tr),
                    ),
                  ),

                  /// Bookmark
                  TextButton(
                    onPressed: () async {
                      await Bookmark.toggle(
                        context: context,
                        category: post.category,
                        postId: post.id,
                      );
                    },
                    child: Login(
                      yes: (uid) => Value(
                        ref: Bookmark.postRef(post.id),
                        builder: (v) => Text(
                          v == null ? T.bookmark.tr : T.unbookmark.tr,
                        ),
                      ),
                      no: () => Text(T.bookmark.tr),
                    ),
                  ),

                  TextButton(
                    onPressed: () => ChatService.instance.showChatRoomScreen(
                      context: context,
                      otherUid: post.uid,
                    ),
                    child: Text(T.chat.tr),
                  ),
                  TextButton(
                    onPressed: () async {
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
                    },
                    child: Text(T.report.tr),
                  ),

                  // BlockButton.textButton(uid: post.uid),

                  const Spacer(),

                  PopupMenuButton(
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
                        await ForumService.instance
                            .showPostUpdateScreen(context: context, post: post);
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
                      }
                    },
                  ),
                ],
              ),
            ),

            /// 가짜 (임시) 코멘트 입력 창
            SliverToBoxAdapter(
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
            ),
            CommentListView(post: post),
          ],
        ),
      ),
    );
  }
}
