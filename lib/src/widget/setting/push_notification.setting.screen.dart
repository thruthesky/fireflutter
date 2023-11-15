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
        title: const Text('Notification Setting'),
      ),
      body: Column(
        children: [
          PushNotificationSetting(
            settingId: NotificationSettingConfig.notifyNewCommentsUnderMyPostsAndComments,
            action: NotificationSettingConfig.notifyNewCommentsUnderMyPostsAndComments,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              title: const Text('Receive notifications of new comments under my posts and comments'),
            ),
          ),
          PushNotificationSetting(
            settingId: NotificationSettingConfig.disableNotifyOnProfileVisited,
            action: NotificationSettingConfig.disableNotifyOnProfileVisited,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              title: const Text('Receive notifications on profile visited'),
            ),
          ),
          PushNotificationSetting(
            settingId: NotificationSettingConfig.disableNotifyOnProfileLiked,
            action: NotificationSettingConfig.disableNotifyOnProfileLiked,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              title: const Text('Receive notifications on profile liked'),
            ),
          ),
          PushNotificationSetting(
            settingId: NotificationSettingConfig.disableNotifyOnPostLiked,
            action: NotificationSettingConfig.disableNotifyOnPostLiked,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              title: const Text('Receive notifications on post liked'),
            ),
          ),
          PushNotificationSetting(
            settingId: NotificationSettingConfig.disableNotifyOnCommentLiked,
            action: NotificationSettingConfig.disableNotifyOnCommentLiked,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              title: const Text('Receive notifications on comment liked'),
            ),
          ),
        ],
      ),
    );
  }
}
