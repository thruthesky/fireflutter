import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/user_setting/user_setting.dart';

import 'package:flutter/material.dart';

/// Display a bell icon with two small ball indicating the subscription of new post and comment.
/// Note, anonymous can use subscriptions.
class PostListPushNotificationIcon extends StatelessWidget {
  const PostListPushNotificationIcon(
    this.categoryId, {
    super.key,
    required this.onChanged,
  });
  final String categoryId;
  final Function(String, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    if (categoryId == '') return const SizedBox.shrink();

    return PopupMenuButton(
        icon: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: mySettingCol
                    .where('action', whereIn: [ActionType.postCreate.name, ActionType.commentCreate.name])
                    .where(
                      'categoryId',
                      isEqualTo: categoryId,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();

                  return snapshot.data!.size > 0
                      ? const Icon(Icons.notifications)
                      : Icon(Icons.notifications_off, color: Theme.of(context).colorScheme.secondary);
                }),
            PushNotificationSetting(
                action: ActionType.postCreate.name,
                categoryId: categoryId,
                toogleValue: false,
                builder: (setting) {
                  return setting == null
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.circle,
                          size: 6,
                          color: Colors.red,
                        );
                }),
            PushNotificationSetting(
              action: ActionType.commentCreate.name,
              categoryId: categoryId,
              toogleValue: false,
              builder: (setting) {
                return setting == null
                    ? const SizedBox.shrink()
                    : const Positioned(
                        right: 0,
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: Colors.blue,
                        ),
                      );
              },
            ),
          ],
        ),
        itemBuilder: (context) => [
              PopupMenuItem(
                value: ActionType.postCreate.name,
                child: PushNotificationSetting(
                  action: ActionType.postCreate.name,
                  categoryId: categoryId,
                  toogleValue: false,
                  builder: (setting) => ListTile(
                    leading: Icon(setting == null ? Icons.notifications_off : Icons.notifications),
                    title: const Text('Post'),
                  ),
                ),
              ),
              PopupMenuItem(
                value: ActionType.commentCreate.name,
                child: PushNotificationSetting(
                  action: ActionType.commentCreate.name,
                  categoryId: categoryId,
                  toogleValue: false,
                  builder: (setting) => ListTile(
                    leading: Icon(setting == null ? Icons.notifications_off : Icons.notifications),
                    title: const Text('Comment'),
                  ),
                ),
              ),
            ],
        onSelected: (value) async {
          final re = await UserSetting.toggle(
            id: "$value.$categoryId",
            action: value,
            categoryId: categoryId,
          );

          onChanged(value, re);
        });
  }
}
