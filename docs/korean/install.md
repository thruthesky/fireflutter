# 설치

FireFlutter 는 단순히 pub.dev 에 있는 것을 Flutter 에 설치한다고 되는 것이 아니다. 앱을 개발하고 운영하기 위해서 필요한 것들이 같이 설치되어야 하는데 예를 들면, 각종 Security Rules 가 반드시 설치되어야 한다.



## Fireflutter 패키지 설치

패키지 설치는 단순히, pub.dev 의 최신 버전을 설치하면 된다.

그러나 개발자 모드로 설치하기 위해서는 아래의 개발자 모드를 참고한다.

## FireFlutter 패키지를 개발자 모드로 설치하기

개발자 모드로 설치하면, FireFlutter 패키지를 좀 더 쉽게 기능 수정(또는 추가)하고 또 PR 할 수 있다.

아래와 같이 개발자 모드로 설치할 수 있다.

- 먼저 [FireFlutter Github](https://github.com/thruthesky/fireflutter) repo 로 부터 Fireflutter 를 포크한다. 

- 그리고 클론한다.

- 그리고 자신만의 branch 를 만든다.

- 그리고 FireFlutter 루트 폴더에서 `apps` 폴더를 만들고, 그 안에 여러분의 앱을 추가하면 된다.

대충 아래와 같은 명령어가 필요할 것이다.

```dart
git fork ...
git clone ...
git checkout -b ...
mkdir apps
cd apps
flutter create your_project
```

- 그리고 추가한 앱의 pubspec.yaml 에서 아래와 같이 FireFlutter 를 dependency 로 추가하면 된다.


```yaml
dependencies:
  fireflutter:
    path: ../..
```

- 만약, FireFlutter 코드의 버그를 수정하거나 새로운 기능을 추가한다면 PR 를 통해서 알려주기를 바란다.


## Firebase Realtime Database Secuirty Rules


[Firebase Realtime Database Security Rules](../assets/realtime_database_security_rules.md) 를 복사해서 Realtime Database 의 Secrity Rulers 에 붙여 넣기 한 다음 저장한다. 물론 자신만의 보안 규칙이 있다면 적절히 수정을 해야 할 것이다.

참고로 Security Rules 는 Security 에 초점을 맞추도록 한다. Security 에서 data validation 이나 기타 security 와 직접적인 관련이 없는 작업은 하지 않는다.

## Firestore Security Rules

[Firebase Firestore Security Rules](../assets/firestore_security_rules.md) 를 Firestore Security Rules 에 복사해 넣으면 된다. 물론 자신만의 보안 규칙이 있다면 적절히 수정을 해야 할 것이다.

참고로 Security Rules 는 Security 에 초점을 맞추도록 한다. Security 에서 data validation 이나 기타 security 와 직접적인 관련이 없는 작업은 하지 않는다.




## 앱 설정 iOS

`FireFlutter` 패키지를 사용하기 위해서 기본적으로 다음과 같은 설정을 해야 합니다. 아래 설정은 사진 업로드에 사용되는 entitlement 입니다.


```xml
<key>NSCameraUsageDescription</key>
<string>This app requires access to the camera to share the photo on profile, chat, forum.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app requires access to the microphone to share vioce with other users.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires access to the photo library to share the photo on profile, chat, forum.</string>
```

## FireFlutter 기본 설치

다음은 FireFlutter 를 적용하는 간단한 예제이다.

- 우선, Firebase 를 플러터 프로젝트에 연결하고,
- FireFlutter 의 `UserService` 를 초기화한다.
- 그리고, 로그인을 UI 를 제공하는 위젯인 `SimpleEmailPasswordLoginForm` 을 화면에 보여준다.

아래의 코드는 어떻게 FireFlutter 를 사용 할 수 있는지에 대한 설명을 하는 것으로, 매우 간단한 코드를 가지고 있으며, 앱 개발 작업을 진행하면서, 필요에 따라 여러가지 코드가 추가되어야 할 것이다.

```dart
import 'package:example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    UserService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Login(
            yes: (uid) => Column(
              children: [
                Text('UID: $uid'),
                ElevatedButton(
                  onPressed: () => UserService.instance.signOut(),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
            no: () => const SimpleEmailPasswordLoginForm(),
          ),
        ],
      ),
    );
  }
}
```

추가적으로 [에러 핸들링](./error_handling.md) 문서와 [빠르게 시작하기](./quick_start.md) 문처를 참고 해 보시면 도움이 될 것입니다.




## Install Cloud Functions

Run the following command to install all the push notification cloud functions.

```sh
% cd firebase/function
% npm run deploy:message
```

And set the end point URL to `MessagingService.instance.init(sendPushNotificationsUrl: ..)`

Run the following command to install typesense related cloud functions.

```sh
% cd firebase/function
% npm run deploy:typesense
```

Run the following command to install a function that manages summarization of all posts under `/posts-all-summary`.
See the [Forum](forum.md) document for the details.

```sh
% cd firebase/function
% npm run deploy:managePostsAllSummary
```

## Dynamic Link 설치





## Initializing TextService

Fireflutter has some UI and you may want to show it in different languages.

And you can use the text translation funtionality in your app.

```dart

/// Call this somewhere while the app boots.
initTextService();

void initTextService() {
  print('--> AppService.initTextService()');

  TextService.instance.texts = {
    ...TextService.instance.texts,
    if ( languageCode == 'ko' ) ...{
      T.ok: '확인',
      T.no: '아니오',
      T.yes: '예',
      T.error: '에러',
      T.dismiss: '닫기',
      Code.profileUpdate: '프로필 수정',
      Code.recentLoginRequiredForResign:
          '회원 탈퇴는 본인 인증을 위해서, 로그아웃 후 다시 로그인 한 다음 탈퇴하셔야합니다.',
      Categories.qna: '질문',
      Categories.discussion: '토론',
      Categories.buyandsell: '장터',
      Categories.info: '정보/알림',
      T.notVerifiedMessage: '본인 인증을 하셔야 전체 기능을 이용 할 수 있습니다.',
      T.chatRoomNoMessageYet: '앗, 아직 메시지가 없습니다.\n채팅을 시작 해 보세요.',
    },
    if ( languageCode == 'en' ) ...{
      T.ok: 'Ok',
      // ...
    }
  };
}
```

## Admin

- See [Admin Doc](admin.md)

## Unit tests

- There are many unit test codes. You can read other document of Fireflutter on how to install and test the unit test codes.
