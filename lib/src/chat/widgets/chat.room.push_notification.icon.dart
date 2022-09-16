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
  String get chatNotify => 'chatNotify.' + widget.uid;
  bool hasDisabledSubscription(settings) {
    return settings[chatNotify] == false;
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (widget.uid == '') return SizedBox.shrink();

    return MySettingsDoc(builder: (settings) {
      if (widget.hideOnDisabled && hasDisabledSubscription(settings))
        return SizedBox.shrink();

      return GestureDetector(
        child: loading == false
            ? Icon(
                hasDisabledSubscription(settings)
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
        onTap: () => toggle(settings),
      );
    });
  }

  toggle(settings) async {
    if (mounted)
      setState(() {
        loading = true;
      });
    print(hasDisabledSubscription(settings));
    await UserService.instance.settings.update({
      chatNotify: hasDisabledSubscription(settings),
    });

    if (mounted)
      setState(() {
        loading = false;
      });
    String msg = !hasDisabledSubscription(settings)
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
