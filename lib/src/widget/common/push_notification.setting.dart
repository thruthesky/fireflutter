import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/user_setting/user_setting.dart';
import 'package:flutter/material.dart';

/// Push Notification Setting
///
/// [toogleValue] If it is set to true, it will toogle the setting when the
/// child widget is tapped (that is created bh the [builder] function).
///
class PushNotificationSetting extends StatelessWidget {
  const PushNotificationSetting({
    super.key,
    required this.action,
    this.roomId,
    this.categoryId,
    required this.builder,
    this.toogleValue = true,
  }) : assert(roomId != null || categoryId != null, 'roomId or categoryId must be not null');
  final String action;
  final String? roomId;
  final String? categoryId;

  final Widget Function(UserSetting?) builder;

  /// Disable tap on the setting.
  final bool toogleValue;

  String get id => roomId ?? ('$action.${categoryId!}');

  @override
  Widget build(BuildContext context) {
    return MySetting(
      id: id,
      builder: (setting) => toogleValue
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await UserSetting.toggle(
                  id: id,
                  action: action,
                  roomId: roomId,
                  categoryId: categoryId,
                );
              },
              child: builder(setting),
            )
          : builder(setting),
    );
  }
}
