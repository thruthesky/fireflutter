import 'package:fireship/fireship.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PostViewScreen extends StatefulWidget {
  static const String routeName = '/PostView';
  const PostViewScreen({super.key, required this.post});

  final PostModel post;

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  PostModel get post => widget.post;
  int? previousNoOfLikes;

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
                child: DisplayPhotos(urls: post.urls),
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  TextButton(
                    onPressed: post.like,
                    child: Value(
                      path: post.ref.child(Field.noOfLikes).path,
                      builder: (no) {
                        previousNoOfLikes = no;
                        return Text('좋아요${likeText(no)}');
                      },
                      onLoading: Text('좋아요${likeText(previousNoOfLikes)}'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ChatService.instance.showChatRoom(
                      context: context,
                      uid: post.uid,
                    ),
                    child: const Text('채팅'),
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
                      await ReportService.instance.report(
                        postId: post.id,
                        category: post.category,
                        reason: re,
                      );
                    },
                    child: const Text('신고'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final re = await my?.block(post.uid);
                      if (!context.mounted) return;
                      toast(
                        context: context,
                        title: re == true ? T.blocked.tr : T.unblocked.tr,
                        message: re == true
                            ? T.blockedMessage.tr
                            : T.unblockedMessage.tr,
                      );
                    },
                    child: const Text('차단'),
                  ),
                  const Spacer(),
                  if (post.uid == myUid)
                    PopupMenuButton(itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('수정'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('삭제'),
                        ),
                      ];
                    }, onSelected: (value) async {
                      if (value == 'edit') {
                        await ForumService.instance
                            .showPostUpdateScreen(context, post: post);
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
                    }),
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
                    context,
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
                            context,
                            post: post,
                            showUploadDialog: true,
                          );
                        },
                        icon: const Icon(Icons.camera_alt),
                      ),
                      const Expanded(child: Text('댓글을 입력하세요')),
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
