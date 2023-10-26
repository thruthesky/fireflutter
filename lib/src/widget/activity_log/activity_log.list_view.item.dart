import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class ActivityLogListTiLeItem extends StatelessWidget {
  const ActivityLogListTiLeItem({
    super.key,
    this.children = const <Widget>[],
    required this.activity,
    required this.actor,
    required this.message,
  });

  final List<Widget> children;
  final ActivityLog activity;
  final User actor;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            activityIcon,
            SizedBox(
              width: 64,
              child: Text(
                dateTimeAgo(activity.createdAt),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(0),
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: children.isEmpty
                  ? Row(
                      children: [
                        UserAvatar(
                          user: actor,
                          size: 52,
                          onTap: () {
                            UserService.instance.showPublicProfileScreen(context: context, user: actor);
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            message,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            UserAvatar(
                              user: actor,
                              size: 52,
                              onTap: () {
                                UserService.instance.showPublicProfileScreen(context: context, user: actor);
                              },
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                message,
                              ),
                            ),
                          ],
                        ),
                        ...children,
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget get activityIcon => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.lightBlue[300]!,
            width: 1,
          ),
        ),
        child: Icon(
          switch ('${activity.type}.${activity.action}') {
            'user.startApp' => Icons.home,
            'user.signin' => Icons.login,
            'user.signout' => Icons.logout,
            'user.resign' => Icons.delete,
            'user.create' => Icons.add,
            'user.update' => Icons.update,
            'user.like' => Icons.thumb_up,
            'user.unlike' => Icons.thumb_down,
            'user.follow' => Icons.add,
            'user.unfollow' => Icons.remove,
            'user.viewProfile' => Icons.person,
            'user.roomOpen' => Icons.chat,
            'user.share' => Icons.share,
            'post.create' => Icons.add,
            'post.update' => Icons.update,
            'post.delete' => Icons.delete,
            'post.like' => Icons.thumb_up,
            'post.unlike' => Icons.thumb_down,
            'post.share' => Icons.share,
            'comment.create' => Icons.add,
            'comment.update' => Icons.update,
            'comment.delete' => Icons.delete,
            'comment.like' => Icons.thumb_up,
            'comment.unlike' => Icons.thumb_down,
            'comment.share' => Icons.share,
            _ => Icons.error,
          },
        ),
      );
}
