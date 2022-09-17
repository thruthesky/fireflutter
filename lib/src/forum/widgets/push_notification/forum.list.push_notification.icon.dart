import 'dart:async';

import 'package:fireflutter/fireflutter.dart';

import 'package:flutter/material.dart';
import 'dart:math' as math; // import this

/// Display a bell icon with two small ball indicating the subscription of new post and comment.
/// Note, anonymous can use subscriptions.
class ForumListPushNotificationIcon extends StatefulWidget {
  ForumListPushNotificationIcon(
    this.categoryId, {
    required this.onChanged,
  });
  final String categoryId;
  final Function(String, bool) onChanged;

  @override
  State<ForumListPushNotificationIcon> createState() =>
      _ForumListPushNotificationIconState();
}

class _ForumListPushNotificationIconState
    extends State<ForumListPushNotificationIcon> {
  bool hasSubscription = false;
  bool hasPostSubscription = false;
  bool hasCommentSubscription = false;

  late StreamSubscription post;
  late StreamSubscription comment;

  String get postTopic => 'post-create.${widget.categoryId}';
  String get commentTopic => 'comment-create.${widget.categoryId}';

  @override
  void initState() {
    super.initState();

    /// listen and re-render
    post =
        UserService.instance.settings.doc(postTopic).snapshot().listen((event) {
      print('snapshot; post create; ${event.data()}');
      setState(() {
        hasPostSubscription = event.exists;
        hasSubscription = hasPostSubscription || hasCommentSubscription;
      });
    });

    /// listen and re-render
    comment = UserService.instance.settings
        .doc(commentTopic)
        .snapshot()
        .listen((event) {
      print('snapshot; comment create; ${event.data()}');
      setState(() {
        hasCommentSubscription = event.exists;
        hasSubscription = hasPostSubscription || hasCommentSubscription;
      });
    });
  }

  @override
  void dispose() {
    post.cancel();
    comment.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryId == '') return SizedBox.shrink();

    return MySettingsBuilder(
      builder: (settings) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            PopupMenuButton<dynamic>(
              padding: EdgeInsets.all(0),
              offset: Offset.fromDirection(2, 46),
              icon: Icon(
                hasSubscription
                    ? Icons.notifications_on
                    : Icons.notifications_off,
                color: hasSubscription
                    ? Color.fromARGB(255, 74, 74, 74)
                    : Color.fromARGB(255, 177, 177, 177),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${widget.categoryId} Subscriptions',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(
                            hasPostSubscription
                                ? Icons.notifications_on
                                : Icons.notifications_off,
                            color: hasPostSubscription
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                          ),
                          Text(
                            ' Post' + " " + widget.categoryId,
                            style: TextStyle(
                              color: hasPostSubscription
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  value: 'post',
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        hasCommentSubscription
                            ? Icons.notifications_on
                            : Icons.notifications_off,
                        color: hasCommentSubscription
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                      Text(
                        ' Comment' + " " + widget.categoryId,
                        style: TextStyle(
                          color: hasCommentSubscription
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  value: 'comment',
                ),
              ],
              onSelected: onNotificationSelected,
            ),
            if (hasPostSubscription)
              Positioned(
                top: 20,
                left: 18,
                child: Transform(
                  transform: Matrix4.rotationY(math.pi),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: Color.fromARGB(255, 196, 255, 239),
                  ),
                ),
              ),
            if (hasCommentSubscription)
              Positioned(
                top: 20,
                right: 18,
                child: Icon(
                  Icons.circle,
                  size: 6,
                  color: Color.fromARGB(255, 255, 202, 132),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Anonymous users can use subscription, but the user must sign-in as anonymous or as a real user.
  onNotificationSelected(dynamic selection) async {
    if (UserService.instance.notSignedInAtAll) {
      ffError(ERROR_SIGN_IN_FIRST_FOR_FORUM_CAETGORY_SUBSCRIPTION);
      return;
    }

    String topic = '';
    String title = "notification";
    bool subscribe = false;

    if (selection == 'post') {
      topic = postTopic;
      title = 'Post ' + title;
      subscribe = !hasPostSubscription;
    } else if (selection == 'comment') {
      topic = commentTopic;
      title = 'Comment ' + title;
      subscribe = !hasCommentSubscription;
    }

    if (subscribe) {
      await UserService.instance.settings.doc(topic).update({
        'action': '$selection-create',
        'category': widget.categoryId,
      });
    } else {
      await UserService.instance.settings.doc(topic).delete();
    }

    widget.onChanged(selection, subscribe);
  }
}
