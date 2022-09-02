import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({
    Key? key,
    this.buttonBuilder,
    this.shareButton,
    required this.post,
    required this.onProfile,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    this.onDislike,
    this.onChat,
    required this.onImageTap,
    this.onHide,
    this.onSendPushNotification,
    this.padding,
    this.onBlockUser,
    this.onUnblockUser,
  }) : super(key: key);

  final Widget Function(String, Function())? buttonBuilder;
  final Widget? shareButton;
  final Post post;
  final Function(String uid) onProfile;
  final Function(Post post) onReport;
  final Function(Post post) onReply;
  final Function(Post post) onEdit;
  final Function(Post post) onDelete;
  final Function(Post post) onLike;
  final Function(Post post)? onDislike;
  final Function(Post post)? onChat;
  final Function()? onHide;
  final Function(Post post)? onSendPushNotification;
  final Function(int index, List<String> fileList) onImageTap;
  final EdgeInsets? padding;

  final Function(String uid)? onBlockUser;
  final Function(String uid)? onUnblockUser;

  @override
  Widget build(BuildContext context) {
    final _onDislike = onDislike == null ? null : () => onDislike!(post);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.isHtmlContent == false)
          ImageList(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            files: post.files,
            onImageTap: (i) => onImageTap(i, post.files),
          ),
        PostContent(
          post,
          onImageTapped: (url) {
            onImageTap(post.files.indexWhere((u) => url == u), post.files);
          },
          padding: padding,
        ),
        ForumPoint(uid: post.uid, point: post.point),
        if (post.summary != '')
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.secondary,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  post.summary,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ButtonBase(
          uid: post.uid,
          isPost: true,
          noOfComments: post.noOfComments,
          onProfile: onProfile,
          onReply: () => onReply(post),
          onReport: () => onReport(post),
          onEdit: () => onEdit(post),
          onDelete: () => onDelete(post),
          onLike: () => onLike(post),
          onDislike: _onDislike,
          onChat: onChat == null ? null : () => onChat!(post),
          onHide: onHide,
          buttonBuilder: buttonBuilder,
          likeCount: post.like,
          dislikeCount: post.dislike,
          shareButton: shareButton,
          onSendPushNotification:
              onSendPushNotification == null ? null : () => onSendPushNotification!(post),
          onBlockUser: onBlockUser,
          onUnblockUser: onUnblockUser,
        ),
      ],
    );
  }
}
