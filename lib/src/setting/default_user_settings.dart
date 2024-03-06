import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DefaultUserSettings extends StatelessWidget {
  const DefaultUserSettings({
    super.key,
    this.languageFilters,
    this.languageSearch = false,
  });

  final List<String>? languageFilters;
  final bool languageSearch;

  @override
  Widget build(BuildContext context) {
    return Value(
      ref: UserSetting.nodeRef.child(myUid!),
      builder: (value) {
        final userSetting = value == null
            ? UserSetting.fromUid(myUid!)
            : UserSetting.fromJson(value, myUid!);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Settings"),
            SwitchListTile(
              value: userSetting.profileViewNotification != false,
              title: const Text('Push Notification on Profile View'),
              subtitle:
                  const Text('Get notified when someone views your profile'),
              onChanged: (v) {
                userSetting.update(
                  profileViewNotification: v,
                );
              },
            ),

            const Divider(height: 32),
            // Language picker

            const Text('Choose your language'),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: LanguagePicker(
                initialValue: userSetting.languageCode,
                filters: languageFilters,
                search: languageSearch,
                onChanged: (v) {
                  userSetting.update(
                    languageCode: v,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
