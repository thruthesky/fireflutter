import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class PostViewScreen extends StatefulWidget {
  static const String routeName = '/PostView';
  const PostViewScreen({super.key, required this.post});

  final PostModel post;

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  PostModel get post => widget.post;
  @override
  void initState() {
    super.initState();
    post.reload().then((x) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: post.onFieldChange(Field.title, (v) => Text(v)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PostMeta(post: post),
            PostContent(post: post),
            Row(
              children: [
                TextButton(
                  onPressed: post.like,
                  child: Database(
                    path: post.ref.child(Field.noOfLikes).path,
                    builder: (no) => Text('좋아요${likeText(no)}'),
                  ),
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
                        reason: re,
                      );
                    },
                    child: const Text('신고')),
                TextButton(
                    onPressed: () async {
                      final re = await my?.block(post.uid);
                      if (mounted) {
                        toast(
                          context: context,
                          title: re == true ? T.blocked.tr : T.unblocked.tr,
                          message: re == true ? T.blockedMessage.tr : T.unblockedMessage.tr,
                        );
                      }
                    },
                    child: const Text('차단')),
                const Spacer(),
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
                    await ForumService.instance.showPostUpdateScreen(context, post: post);
                    post.reload();
                  } else if (value == 'delete') {
                    // await post.delete();
                    // Navigator.of(context).pop();
                  }
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
