import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_app/home/forum/post/block.button.dart';

class CustomPostViewScreen extends StatelessWidget {
  const CustomPostViewScreen({
    super.key,
    required this.dateAgo,
    required this.post,
    required this.snapshot,
  });
  final AsyncSnapshot<User?> snapshot;
  final Post post;
  final DateTime dateAgo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: sizeSm),
      child: SingleChildScrollView(
        child: PostCard(
          post: post,
          customHeaderBuilder: (context, post) => customHeader(context, post),
          customMainContentBuilder: (context, post) => Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(sizeSm, 0, sizeSm, sizeXs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: sizeSm,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: sizeSm),
                    Text(post.content),
                  ],
                ),
              ),
            ],
          ),
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
              SizedBox(
                height: 30,
                width: 200,
                child: Row(
                  children: [
                    Text(
                      snapshot.data!.name,
                      style: TextStyle(
                        color: Theme.of(context).shadowColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // BLOCK / UNBLOCK HERE
                    if (snapshot.data!.uid != myUid) BlockUnblock(snapshot: snapshot),
                  ],
                ),
              ),
              DateTimeText(
                dateTime: dateAgo,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: sizeSm - 5,
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
