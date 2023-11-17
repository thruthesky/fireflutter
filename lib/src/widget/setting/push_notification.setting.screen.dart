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
        title: Text(tr.titleNotificationSetting),
      ),
      body: Column(
        children: [
          PushNotificationSetting(
            settingId: NotificationSettingConfig.disableNotifyNewCommentsUnderMyPostsAndComments,
            action: NotificationSettingConfig.disableNotifyNewCommentsUnderMyPostsAndComments,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              // title: const Text('Receive notifications of new comments under my posts and comments'),
              title: Text(tr.notificationSettingNewComments),
            ),
          ),
          PushNotificationSetting(
            settingId: NotificationSettingConfig.disableNotifyOnProfileVisited,
            action: NotificationSettingConfig.disableNotifyOnProfileVisited,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              // title: const Text('Receive notifications on profile visited'),
              title: Text(tr.notificationSettingProfileVisited),
            ),
          ),
          PushNotificationSetting(
            settingId: NotificationSettingConfig.disableNotifyOnProfileLiked,
            action: NotificationSettingConfig.disableNotifyOnProfileLiked,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              // title: const Text('Receive notifications on profile liked'),
              title: Text(tr.notificationSettingProfileLiked),
            ),
          ),
          PushNotificationSetting(
            settingId: NotificationSettingConfig.disableNotifyOnPostLiked,
            action: NotificationSettingConfig.disableNotifyOnPostLiked,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              // title: const Text('Receive notifications on post liked'),
              title: Text(tr.notificationSettingPostLiked),
            ),
          ),
          PushNotificationSetting(
            settingId: NotificationSettingConfig.disableNotifyOnCommentLiked,
            action: NotificationSettingConfig.disableNotifyOnCommentLiked,
            toogleValue: true,
            builder: (setting) => ListTile(
              leading: Icon(setting == null ? Icons.notifications_active : Icons.notifications_off),
              // title: const Text('Receive notifications on comment liked'),
              title: Text(tr.notificationSettingCommentLiked),
            ),
          ),
        ],
      ),
    );
  }
}
