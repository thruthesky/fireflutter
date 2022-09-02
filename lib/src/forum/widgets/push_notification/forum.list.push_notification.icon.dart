import '../../../../fireflutter.dart';

import './forum.list.push_notification.popup_button.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math; // import this

class ForumListPushNotificationIcon extends StatelessWidget {
  ForumListPushNotificationIcon(
    this.categoryId, {
    // required this.onError,
    // required this.onSigninRequired,
    required this.onChanged,
    this.size,
  });
  final String categoryId;
  final double? size;
  // final Function onError;
  // final Function onSigninRequired;
  final Function(String, bool) onChanged;

  bool get hasSubscription {
    /// TODO check if the user has subscription of the forum cateogry
    return true;
    // return _.settings
    //         .hasSubscription(NotificationOptions.post(categoryId), 'forum') ||
    //     _.settings
    //         .hasSubscription(NotificationOptions.comment(categoryId), 'forum');
  }

  bool get hasPostSubscription {
    /// TODO check if the user has subscription of the forum cateogry
    return true;
    // return _.settings.hasSubscription(NotificationOptions.post(categoryId), 'forum');
  }

  bool get hasCommentSubscription {
    /// TODO check if the user has subscription of the forum cateogry
    return true;
    // return _.settings.hasSubscription(NotificationOptions.comment(categoryId), 'forum');
  }

  @override
  Widget build(BuildContext context) {
    if (categoryId == '') return SizedBox.shrink();

    return UserSettingDoc(
      builder: (settings) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            ForumListPushNotificationPopUpButton(
              icon: Icon(
                hasSubscription ? Icons.notifications_on : Icons.notifications_off,
                color: hasSubscription
                    ? Color.fromARGB(255, 74, 74, 74)
                    : Color.fromARGB(255, 177, 177, 177),
              ),
              items: [
                PopupMenuItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$categoryId Subscriptions',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(
                            hasPostSubscription ? Icons.notifications_on : Icons.notifications_off,
                            color: hasPostSubscription
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                          ),
                          Text(
                            ' Post' + " " + categoryId,
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
                        hasCommentSubscription ? Icons.notifications_on : Icons.notifications_off,
                        color: hasCommentSubscription
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                      Text(
                        ' Comment' + " " + categoryId,
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

  onNotificationSelected(dynamic selection) async {
    // if (_.notSignedIn) {
    //   onSigninRequired();
    //   return;
    // }

    /// TODO check if the user has subscription of the forum cateogry

    // String topic = '';
    // String title = "notification";
    // if (selection == 'post') {
    //   topic = NotificationOptions.post(categoryId);
    //   title = 'post ' + title;
    // } else if (selection == 'comment') {
    //   topic = NotificationOptions.comment(categoryId);
    //   title = 'comment ' + title;
    // }

    // await _.settings.toggleSubscription(
    //   topic,
    //   'forum',
    // );
    // return onChanged(
    //   selection,
    //   _.settings.hasSubscription(topic, 'forum'),
    // );
  }
}
