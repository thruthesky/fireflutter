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
  final PostModel post;
  final Function(String uid) onProfile;
  final Function(PostModel post) onReport;
  final Function(PostModel post) onReply;
  final Function(PostModel post) onEdit;
  final Function(PostModel post) onDelete;
  final Function(PostModel post) onLike;
  final Function(PostModel post)? onDislike;
  final Function(PostModel post)? onChat;
  final Function()? onHide;
  final Function(PostModel post)? onSendPushNotification;
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
          onSendPushNotification: onSendPushNotification == null
              ? null
              : () => onSendPushNotification!(post),
          onBlockUser: onBlockUser,
          onUnblockUser: onUnblockUser,
        ),
      ],
    );
  }
}
