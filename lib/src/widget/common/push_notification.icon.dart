// import 'package:fireflutter/src/service/user.settings.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/user_setting/user_setting.dart';
import 'package:flutter/material.dart';

/// Push Notification Icon
///
/// This displays an icon that toggles the push notification setting.
///
/// If you need to rebuild your own child, use PushNotificationSetting.
class PushNotificationIcon extends StatelessWidget {
  const PushNotificationIcon({
    super.key,
    required this.action,
    this.roomId,
    this.categoryId,
  }) : assert(roomId != null || categoryId != null, 'roomId or categoryId must be not null');
  final String action;
  final String? roomId;
  final String? categoryId;

  String get id => roomId ?? (action + categoryId!);

  @override
  Widget build(BuildContext context) {
    return MySetting(
      id: id,
      builder: (setting) => IconButton(
        onPressed: () async {
          await UserSetting.toggle(
            id: id,
            action: action,
            roomId: roomId,
            categoryId: categoryId,
          );
        },
        icon: Icon(setting == null ? Icons.notifications_off : Icons.notifications_active),
      ),
    );
  }
}
