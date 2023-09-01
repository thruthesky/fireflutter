import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostListCategorySubscription extends StatelessWidget {
  const PostListCategorySubscription(
    this.categoryId, {
    Key? key,
  }) : super(key: key);

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return PostListPushNotificationIcon(
      categoryId,
      onChanged: (String postOrComment, bool subscribed) {
        tapSnackbar(
          context: context,
          title: subscribed ? 'Subscription' : 'Unsubscription',
          message:
              'You have ${subscribed ? 'subscribed' : 'unsubscribed'} the $categoryId $postOrComment subscription.',
          icon: Icon(
            subscribed ? Icons.notification_add : Icons.notifications_off,
            color: Colors.white,
          ),
          duration: 20,
          onTap: (x) => x(),
        );
      },
    );
  }
}
