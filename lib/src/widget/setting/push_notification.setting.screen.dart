import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PushNotificationSettingScreen extends StatefulWidget {
  const PushNotificationSettingScreen({super.key});

  @override
  State<PushNotificationSettingScreen> createState() => _PushPushNotificationSettingScreenState();
}

class _PushPushNotificationSettingScreenState extends State<PushNotificationSettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('PushNotificationSettingBack'),
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notification Setting'),
      ),
      body: Column(
        children: [
          PushNotificationSetting(
            settingId: NotificationSettingConfig.notifyNewCommentsUnderMyPostsAndComments.name,
            action: NotificationSettingConfig.notifyNewCommentsUnderMyPostsAndComments.name,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_off : Icons.notifications_active),
              title: const Text('Receive notifications of new comments under my posts and comments'),
            ),
          ),
        ],
      ),
    );
  }
}
