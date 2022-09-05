import 'package:fireflutter/fireflutter.dart';

import 'package:flutter/material.dart';

class ChatRoomPushNotificationIcon extends StatefulWidget {
  ChatRoomPushNotificationIcon(
    this.uid, {
    this.size,
    this.hideOnDisabled = false,
  });
  final String uid;
  final double? size;
  final bool hideOnDisabled;
  @override
  _ChatRoomPushNotificationIconState createState() =>
      _ChatRoomPushNotificationIconState();
}

class _ChatRoomPushNotificationIconState
    extends State<ChatRoomPushNotificationIcon> {
  /// TODO global controller
  // Controller get _ => Controller.of;
  bool hasDisabledSubscription() {
    return true;
    // /// TODO global controller
    // return _.settings
    //     .hasDisabledSubscription('chatNotify' + widget.uid, 'chat');
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (widget.uid == '') return SizedBox.shrink();
    if (widget.hideOnDisabled && hasDisabledSubscription())
      return SizedBox.shrink();

    return GestureDetector(
      child: loading == false
          ? Icon(
              hasDisabledSubscription()
                  ? Icons.notifications_off
                  : Icons.notifications,
              color: Colors.grey.shade700,
              size: widget.size,
            )
          : SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator.adaptive(),
            ),
      onTap: () => toggle(),
    );
  }

  toggle() async {
    /// TODO global controller
    // if (_.notSignedIn) {
    //   return showDialog(
    //     context: context,
    //     builder: (c) => AlertDialog(
    //       title: Text('notifications'),
    //       content: Text('login_first'),
    //       actions: [
    //         ElevatedButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: Text('Close'),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    if (mounted)
      setState(() {
        loading = true;
      });

    /// TODO global controller
    // await _.settings.toggleTopic(
    //     'chatNotify' + widget.uid, 'chat', hasDisabledSubscription());
    if (mounted)
      setState(() {
        loading = false;
      });
    String msg = hasDisabledSubscription()
        ? 'Unsubscribed success'
        : 'Subscribed success';
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Notification'),
        content: Text(msg),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
