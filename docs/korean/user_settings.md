# 사용자 설정

- `user-settings/<uid>` 에 사용자 설정이 저장된다.

- `enablePushNotificationOnProfileView` 에 true 를 저장하면, 누가 나의 프로필을 보면 나에게 푸시 알림이 도착한다.
  단, `UserService.instance.init(enablePushNotificationOnProfileView: true)` 와 같이 설정을 해야지만, 푸시 알림이 동작한다.


- `langaugeCode` 언어 코드 설정. 사용자가 쓰는 기본 언어이다. 이 값은 앱이 최초 실행 될 때, 핸드폰에서 사용하는 언어가 설정이 되도록 해 주면 좋다. 그리고 설정에서 수정 할 수 있도록 하면 된다.





## 사용자 설정 화면 UI

FireFlutter 에서 제공하는 기본 데이터 구조와 코드를 사용하여 모든 것을 직접 작성을 할 수 있다. 하지만, 기존의 코드를 활용하면 더욱 쉽게 작업을 할 수 있다.



```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/global.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/Settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(md),
        child: DefaultUserSettings(
          languageFilters: ['en', 'ko', 'vi', 'lo', 'my', 'th'],
          languageSearch: false,
        ),
      ),
    );
  }
}
```


### 커스터마이징 언어 선택 UI

- `languagePickerXxxxxBuilder` 를 통해서 커스텀 디자인을 할 수 있다.


```dart
DefaultUserSettings(
  languageFilters: const ['en', 'ko', 'vi', 'lo', 'my', 'th'],
  languageSearch: false,
  languagePickerLabelBuilder: (label) => Text(label!.language.tr),
  languagePickerHeaderBuilder: () => Text(T.chooseYourLanguage.tr),
  languagePickerItemBuilder: (language) {
    return Column(
      children: [
        Text(
          '  ${'${language.value}'.tr} ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize:
                Theme.of(context).textTheme.titleMedium!.fontSize,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        spaceXxs,
      ],
    );
  },
),
```