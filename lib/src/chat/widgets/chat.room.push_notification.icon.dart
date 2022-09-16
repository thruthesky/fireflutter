import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomPushNotificationIcon extends StatelessWidget {
  const ChatRoomPushNotificationIcon({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final ref = UserService.instance.settings.col.doc("chat.$uid");
    return DocumentBuilder(
        ref: ref,
        builder: (doc) {
          // if the setting document exists, it means, the user un-subscribed.
          final bool subscribed = doc == null;
          return IconButton(
            icon: Icon(
              subscribed ? Icons.notifications : Icons.notifications_off,
            ),
            onPressed: () async {
              if (subscribed) {
                // subscribed means, settings file does not exsits.
                // To un-subscribe, create the settings file.
                await ref.set({'uid': 'un-subscribed'});
              } else {
                // To subscribe, delete the settings file.
                await ref.delete();
              }
            },
          );
        });
  }
}
