import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ActivityLogIcons extends StatelessWidget {
  const ActivityLogIcons({
    super.key,
    required this.activity,
    this.icon,
  });

  final Widget? icon;
  final ActivityLog activity;

  @override
  Widget build(BuildContext context) {
    final activityString = '${activity.type}.${activity.action}';

    Icon? defaultIcon;
    if (activityString == "${Log.type.user}.${Log.user.startApp}") {
      defaultIcon = const Icon(Icons.home);
    } else if (activityString == "${Log.type.user}.${Log.user.signin}") {
      defaultIcon = const Icon(Icons.login);
    } else if (activityString == "${Log.type.user}.${Log.user.signout}") {
      defaultIcon = const Icon(Icons.logout);
    } else if (activityString == "${Log.type.user}.${Log.user.resign}") {
      defaultIcon = const Icon(Icons.delete);
    } else if (activityString == "${Log.type.user}.${Log.user.create}") {
      defaultIcon = const Icon(Icons.add);
    } else if (activityString == "${Log.type.user}.${Log.user.update}") {
      defaultIcon = const Icon(Icons.update);
    } else if (activityString == "${Log.type.user}.${Log.user.like}") {
      defaultIcon = const Icon(Icons.thumb_up);
    } else if (activityString == "${Log.type.user}.${Log.user.unlike}") {
      defaultIcon = const Icon(Icons.thumb_down);
    } else if (activityString == "${Log.type.user}.${Log.user.follow}") {
      defaultIcon = const Icon(Icons.bookmark_add_outlined);
    } else if (activityString == "${Log.type.user}.${Log.user.unfollow}") {
      defaultIcon = const Icon(Icons.bookmark_remove_outlined);
    } else if (activityString == "${Log.type.user}.${Log.user.viewProfile}") {
      defaultIcon = const Icon(Icons.person_search_outlined);
    } else if (activityString == "${Log.type.user}.${Log.user.share}") {
      defaultIcon = const Icon(Icons.share);
    } else if (activityString == "${Log.type.post}.${Log.post.create}") {
      defaultIcon = const Icon(Icons.add);
    } else if (activityString == "${Log.type.post}.${Log.post.update}") {
      defaultIcon = const Icon(Icons.update);
    } else if (activityString == "${Log.type.post}.${Log.post.delete}") {
      defaultIcon = const Icon(Icons.delete);
    } else if (activityString == "${Log.type.post}.${Log.post.like}") {
      defaultIcon = const Icon(Icons.thumb_up_outlined);
    } else if (activityString == "${Log.type.post}.${Log.post.unlike}") {
      defaultIcon = const Icon(Icons.thumb_down_outlined);
    } else if (activityString == "${Log.type.post}.${Log.post.share}") {
      defaultIcon = const Icon(Icons.share);
    } else if (activityString == "${Log.type.comment}.${Log.comment.create}") {
      defaultIcon = const Icon(Icons.add_comment);
    } else if (activityString == "${Log.type.comment}.${Log.comment.update}") {
      defaultIcon = const Icon(Icons.insert_comment_outlined);
    } else if (activityString == "${Log.type.comment}.${Log.comment.delete}") {
      defaultIcon = const Icon(Icons.delete_forever_outlined);
    } else if (activityString == "${Log.type.comment}.${Log.comment.like}") {
      defaultIcon = const Icon(Icons.thumb_up_outlined);
    } else if (activityString == "${Log.type.comment}.${Log.comment.unlike}") {
      defaultIcon = const Icon(Icons.thumb_down_outlined);
    } else if (activityString == "${Log.type.comment}.${Log.comment.share}") {
      defaultIcon = const Icon(Icons.share);
    } else if (activityString == "${Log.type.chat}.${Log.chat.roomOpen}") {
      defaultIcon = const Icon(Icons.chat_bubble_outline);
    } else {
      defaultIcon = const Icon(Icons.help_center_outlined);
    }

    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.tone(70), //Colors.lightBlue[300]!,
            width: 2,
          ),
        ),
        child: icon ?? defaultIcon);
  }
}
