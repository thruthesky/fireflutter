import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class ButtonBase extends StatelessWidget {
  const ButtonBase({
    required this.uid,
    this.noOfComments = 0,
    required this.isPost,
    required this.onProfile,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    this.onDislike,
    this.onChat,
    this.onHide,
    this.likeCount = 0,
    this.dislikeCount = 0,
    required this.buttonBuilder,
    this.shareButton,
    this.onSendPushNotification,
    this.onBlockUser,
    this.onUnblockUser,
    Key? key,
  }) : super(key: key);

  final String uid;
  final bool isPost;
  final int noOfComments;
  final Function(String uid) onProfile;
  final Function() onReply;
  final Function() onReport;
  final Function() onEdit;
  final Function() onDelete;
  final Function() onLike;
  final Function()? onDislike;
  final Function()? onChat;
  final Function()? onHide;
  final Widget? shareButton;
  final Function()? onSendPushNotification;
  final Function(String uid)? onBlockUser;
  final Function(String uid)? onUnblockUser;

  final Widget Function(String, Function())? buttonBuilder;

  bool get isMine {
    return UserService.instance.uid == uid;
  }

  bool get isAdmin {
    return UserService.instance.isAdmin;
  }

  final int likeCount;
  final int dislikeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _button(
            isPost
                ? 'Reply${noOfComments > 0 ? '($noOfComments)' : ''}'
                : 'Reply',
            onReply),
        // _button('Report', onReport),
        _button('Like${likeCount > 0 ? " $likeCount" : ""}', onLike),
        if (onDislike != null)
          _button(
              'Dislike${dislikeCount > 0 ? " $dislikeCount" : ""}', onDislike!),
        if (!isMine && onChat != null) _button('Chat', onChat!),
        if (shareButton != null) shareButton!,
        Spacer(),
        PopupMenuButton<String>(
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
            child: Icon(Icons.more_vert),
            // color: Colors.blue,
          ),
          initialValue: '',
          itemBuilder: (BuildContext context) => [
            if (!isMine)
              PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
            if (isMine)
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
            if (isMine || isAdmin)
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            if (isAdmin &&
                onBlockUser != null &&
                UserService.instance.isNotBlocked(uid))
              PopupMenuItem<String>(
                value: 'block',
                child: Text('Block User', style: TextStyle(color: Colors.red)),
              ),
            if (isAdmin &&
                onUnblockUser != null &&
                UserService.instance.isBlocked(uid))
              PopupMenuItem<String>(
                value: 'unblock',
                child:
                    Text('Unblock User', style: TextStyle(color: Colors.green)),
              ),
            PopupMenuDivider(),
            if (!isMine)
              PopupMenuItem<String>(
                value: 'report',
                child: Text('Report', style: TextStyle(color: Colors.red)),
              ),
            if (isAdmin && onSendPushNotification != null)
              PopupMenuItem<String>(
                value: 'notification',
                child: Text(
                  'Send push notification',
                ),
              ),
            if (isPost && onHide != null)
              PopupMenuItem<String>(
                  value: 'hide_post', child: Text('Hide Post')),
            PopupMenuItem<String>(value: 'close_menu', child: Text('Close')),
          ],
          onSelected: (String value) async {
            if (value == 'profile') {
              return onProfile(uid);
            }

            if (value == 'hide_post') {
              onHide!();
              return;
            }

            if (value == 'report') {
              onReport();
              return;
            }
            if (value == 'edit') {
              onEdit();
              return;
            }
            if (value == 'delete') {
              onDelete();
              return;
            }

            if (value == 'notification') {
              onSendPushNotification!();
              return;
            }

            if (value == 'block') {
              onBlockUser!(uid);
              return;
            }

            if (value == 'unblock') {
              onUnblockUser!(uid);
              return;
            }
          },
        )
      ],
    );
  }

  Widget _button(String label, Function() callback) {
    return buttonBuilder != null
        ? buttonBuilder!(label, callback)
        : TextButton(
            onPressed: callback,
            child: Text(
              label,
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          );
  }
}
