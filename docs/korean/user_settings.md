# 사용자 설정

- `user-settings/<uid>` 에 사용자 설정이 저장된다.
  - 사용자 설정 정보가 커질 수 있어 `users` 노드에 모두 저장하지 않고 분리한다.

- `user-settings` 노드는 `users` 와 마찬가지로 초기화를 하면 실시간 업데이트된다.

- `/user-settings/<uid>/{profileViewNotification: true}` 와 같이 `profileViewNotification` 에 true 를 저장하면, 누가 나의 프로필을 보면 나에게 푸시 알림이 도착한다.


- `/user-settings/<uid>/{commentNotification: true}` 와 같이 `commentNotification` 에 true 를 저장하면, 누가 나의 글 또는 코멘트 아래에 새 코멘트를 작성하면 나에게 푸시 알림이 도착한다.
  - 앱 기획 또는 로직을 작성 할 때, 신규 회원이 가입하자 마자 자동으로 이 값을 true 로 저장할 수 있다. 그러면 자동으로 자신의 글 아래에 새로운 코멘트를 푸시 알림 받는 것이 된다. 사용자가 푸시 알림을 원하지 않을 경우를 대비해 메뉴에서 설정을 해제 할 수 있도록 해 놓아야 할 것이다.
  - 새 코멘트 푸시 알림 전송 관련해서는 [푸시 알림 문서의 코멘트 구독](./messaging.md#코멘트-구독)을 참고한다.

- `langaugeCode` 언어 코드 설정. 사용자가 쓰는 기본 언어이다. 이 값은 앱이 최초 실행 될 때, 핸드폰에서 사용하는 언어가 설정이 되도록 해 주면 좋다. 그리고 설정에서 수정 할 수 있도록 하면 된다.



## UserSettingService

- `UserSettingServic` 는 `/user-settings/<my-uid>` 의 설정 값을 관리하는 서비스이다.
- `UserSetting` model 클래스는 사용자 설정 값에 대한 CRUD 및 기본적인 동작을 포함한다.
- `UserSettingService` 를 초기화하면 실시간으로 설정 값이 `UserSettingService.instance.setting` 에 업데이트된다.
  - 그리고 보다 이 변수를 직접 액세스 할 수 있으며 `UserModel.setting` 에 링크되어져 있다. 즉, `my.setting.languageCode` 와 같이 쓸 수 있다.
- 앱 처음 시작시, 아래와 같이 초기화를 해 주면 된다.

```dart
UserSettingService.instance.init(
  defaultCommentNotification: false,
);
```

- 위에서 `defaultCommentNotification` 은 사용자가 처음 앱을 실행 할 때 (또는 로그인 할 때) 새 코멘트 알림을 기본적으로 on 하는 것이다. 그래서 자신의 글 또는 코멘트에 새로운 코멘트가 작성되면 알림을 받도록 하는 것이다. 만약, 이 값을 false 로 하면, 사용자가 설정에서 on 을 하기 전에는 새 코멘트 알림을 받지 못한다. 즉, 자동으로 코멘트 알림을 해 주기 위한 것이다.


## 설정 관련 위젯


- `MySetting` 위젯은 로그인한 사용자의 설정이 변경되면 위젯을 다시 빌드한다.

- `MySettingField` 위젯은 내부적으로 `Value` 위젯을 쓰며 사용자 설정의 특정(개별, 하위) 노드 값 1개를 observe 하고 값이 변경되면 위젯을 다시 빌드한다.



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


## 사용자 설정 추천 코딩 방법


- 사용자 설정은 `UserSetting` 모델 클래스가 모델링을 한다. 이 클래스는 기본적인 CRUD 를 가지고 있으며, 로그인한 사용자 뿐만아니라 로그인하지 않은 사용자의 정보도 담을 수 있다. 단, 설정 정보 CRUD 는 로그인한 사용자의 것만 가능하다.
- 로그인한 사용자의 설정은 `UserSettingService` 에 의해서 관리된다.
  - 앱 시작시 `UserSettingService.instance.init()` 을 한번 실행을 하면 되며,
  - 설정이 변경되면, `UserSettingService.instance.changes` 이벤트가 발생한다.


- 사용자 설정이 업데이트 되면, 위젯을 rebuild 하고 싶은 경우, `MySetting` 을 사용하면 된다. 이 위젯은 사용자 정보 전체를 observe 한다.

- 만약, 사용자 설정 정보 전체가 아니라 하나의 필드만 observe 하려고 한다면, 아래와 같이 `MySettingField` 를 통해서 개별 field 를 observe 해서, 위젯을 rebuild 하고 설정 정보를 업데이트 할 수 있다.
  - 이렇게 하나의 (필요한) 필드만 observe 하면, 화면 깜빡임이 줄어든다.

```dart
MySettingField(
  field: Field.profileViewNotification,
  builder: (v, ref) => SwitchListTile(
    value: v == true,
    onChanged: (value) => ref.set(value),
    title: const Text("프로필 알림"),
    subtitle: const Text("누군가 나의 프로필을 보면 알림을 받습니다."),
  ),
),
```


