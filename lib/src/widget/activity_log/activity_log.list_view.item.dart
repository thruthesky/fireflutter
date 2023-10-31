import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class ActivityLogListTiLeItem extends StatelessWidget {
  const ActivityLogListTiLeItem({
    super.key,
    this.children = const <Widget>[],
    required this.activity,
    required this.actor,
    required this.message,
    this.icon,
  });

  final List<Widget> children;
  final ActivityLog activity;
  final User actor;
  final String message;

  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(
                height: sizeSm,
              ),
              activityIcon,
              const SizedBox(height: sizeXxs),
              SizedBox(
                width: 64,
                child: Text(
                  dateTimeShort(activity.createdAt),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(width: sizeXs),
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(0),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 24),
                child: children.isEmpty
                    ? Row(
                        children: [
                          UserAvatar(
                            user: actor,
                            size: 40,
                            radius: 20,
                            onTap: () {
                              UserService.instance.showPublicProfileScreen(context: context, user: actor);
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              message,
                              style: Theme.of(context).textTheme.bodyMedium,
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
                                size: 40,
                                radius: 20,
                                onTap: () {
                                  UserService.instance.showPublicProfileScreen(context: context, user: actor);
                                },
                              ),
                              const SizedBox(width: sizeXs),
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
      ),
    );
  }

  Widget get activityIcon => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.lightBlue[300]!,
            width: 1,
          ),
        ),
        child: icon ??
            Icon(
              switch ('${activity.type}.${activity.action}') {
                'user.startApp' => Icons.home,
                'user.signin' => Icons.login,
                'user.signout' => Icons.logout,
                'user.resign' => Icons.delete,
                'user.create' => Icons.add,
                'user.update' => Icons.update,
                'user.like' => Icons.thumb_up,
                'user.unlike' => Icons.thumb_down,
                'user.follow' => Icons.bookmark_add_outlined,
                'user.unfollow' => Icons.bookmark_remove_outlined,
                'user.viewProfile' => Icons.person_search_outlined,
                'user.roomOpen' => Icons.chat_bubble_outline,
                'user.share' => Icons.share,
                'post.create' => Icons.add,
                'post.update' => Icons.update,
                'post.delete' => Icons.delete,
                'post.like' => Icons.thumb_up_outlined,
                'post.unlike' => Icons.thumb_down_outlined,
                'post.share' => Icons.share,
                'comment.create' => Icons.add_comment,
                'comment.update' => Icons.insert_comment_outlined,
                'comment.delete' => Icons.delete_forever_outlined,
                'comment.like' => Icons.thumb_up_outlined,
                'comment.unlike' => Icons.thumb_down_outlined,
                'comment.share' => Icons.share,
                _ => Icons.help_center_outlined,
              },
            ),
      );
}
