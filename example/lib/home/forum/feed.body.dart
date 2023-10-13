import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_app/home/forum/post/create.post.dart';
import 'package:new_app/page.essentials/inits.dart';
import 'package:new_app/page.essentials/app.bar.dart';

class FeedBody extends StatefulWidget {
  const FeedBody({
    super.key,
  });

  @override
  State<FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<FeedBody> {
  final controller = TextEditingController();
  String categName = '';

  @override
  void initState() {
    super.initState();
    customizePostInit(categName);
    ChatService.instance.customize.chatRoomAppBarBuilder = ({room, user}) => customAppBar(context, room);
    PostService.instance.init(
      enableSeenBy: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: sizeXs),
          Expanded(
            child: PostListView(
              itemBuilder: (context, post) => InkWell(
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (context, _, __) => Dialog(
                      child: CommentListView(
                        post: post,
                        itemBuilder: (context, comment) => CommentOneLineListTile(comment: comment, post: post),
                      ),
                    ),
                  );
                },
                child: PostCard(
                  post: post,
                  commentSize: 3,
                  shareButtonBuilder: (post) => IconButton(
                    onPressed: () {
                      // ShareService.instance.showBottomSheet();
                    },
                    icon: const Icon(Icons.share, size: sizeSm),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding topBarWidgets(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: sizeSm, right: sizeSm),
      child: Row(
        children: [
          UserAvatar(
            user: my,
            radius: sizeXl,
            size: sizeXl,
            // onTap: () => context.push(UserPage.routeName),
          ),
          const SizedBox(width: sizeSm),
          PostField(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const PostCreate(),
              );
            },
          ),
          const SizedBox(width: sizeXs),
          IconButton(
            onPressed: () async {
              final url = await StorageService.instance.upload(context: context);
              debugPrint('url: $url');
              if (url != null && mounted) {
                setState(() {});
              }
            },
            icon: FaIcon(
              FontAwesomeIcons.image,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
