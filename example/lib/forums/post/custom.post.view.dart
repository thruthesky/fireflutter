import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomPostViewScreen extends StatelessWidget {
  const CustomPostViewScreen({
    super.key,
    required this.dateAgo,
    required this.post,
    required this.snapshot,
  });
  final AsyncSnapshot<User?> snapshot;
  final Post post;
  final String dateAgo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: sizeSm),
      child: SingleChildScrollView(
        child: PostCard(
          post: post,
          customHeaderBuilder: (context, post) => customHeader(context, post),
        ),
      ),
    );
  }

  Padding customHeader(BuildContext context, Post post) {
    return Padding(
      padding: const EdgeInsets.all(sizeSm),
      child: Row(
        children: [
          UserAvatar(
            user: snapshot.data,
            radius: sizeXl,
            size: sizeXl,
          ),
          const SizedBox(width: sizeSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.data!.name,
                style: TextStyle(
                  color: Theme.of(context).shadowColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                dateAgo,
                style: TextStyle(
                  color: Theme.of(context).shadowColor.withAlpha(150),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (snapshot.data!.uid == myUid)
            IconButton(
              onPressed: () => PostService.instance.showEditScreen(context, categoryId: post.categoryId, post: post),
              icon: const FaIcon(FontAwesomeIcons.pen),
            )
          else
            popUpMenu(post, context),
        ],
      ),
    );
  }

  PopupMenuButton<String> popUpMenu(Post post, BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        const PopupMenuItem(value: "reply", child: Text("Reply")),
        if (post.isMine) PopupMenuItem(value: "edit", child: Text(tr.edit)),
        const PopupMenuItem(value: "report", child: Text("Report")),
        if (!post.isMine)
          PopupMenuItem(
            value: 'block',
            child: Database(
              path: pathBlock(post.uid),
              builder: (value, p) => Text(value == null ? tr.block : tr.unblock),
            ),
          ),
      ],
      onSelected: (value) async {
        if (value == "reply") {
          CommentService.instance.showCommentEditBottomSheet(context, post: post);
        } else if (value == "edit") {
          PostService.instance.showEditScreen(context, post: post);
        } else if (value == 'report') {
          ReportService.instance.showReportDialog(context: context, postId: post.id);
        } else if (value == 'block') {
          final blocked = await toggle(pathBlock(post.uid));
          toast(
            title: blocked ? tr.block : tr.unblock,
            message: blocked ? tr.blockMessage : tr.unblockMessage,
          );
        }
      },
    );
  }
}
