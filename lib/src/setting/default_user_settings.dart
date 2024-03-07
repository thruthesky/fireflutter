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
            Text(T.setting.tr),
            SwitchListTile(
              value: userSetting.profileViewNotification != false,
              title: Text(T.pushNotificationOnProfileView.tr),
              subtitle: Text(T.getNotifiedWhenSomeoneViewYourProfile.tr),
              onChanged: (v) {
                userSetting.update(
                  profileViewNotification: v,
                );
              },
            ),
            const Divider(height: 32),
            // Language picker

            Text(T.chooseYourLanguage.tr),
            LanguagePicker.tile(
              initialValue: userSetting.languageCode,
              filters: languageFilters,
              search: languageSearch,
              onChanged: (v) {
                userSetting.update(
                  languageCode: v,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
