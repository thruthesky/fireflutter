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

참고로, 아직, Firestore 에서 어떤 index 를 미리 만들어야 하는지 목록을 해 놓지 못하고 있다. 그래서 index 에러가 나면 콘솔에서 링크를 복사해서 index 를 생성해 주어야한다. 조만간 필요한 index 를 이곳에 나열을 할 예정이다.



## Storage Security Rules

[Firebase Storage Security Rules](../assets/storage_security_rules.md)를 Storage Rules 로 복사해 넣는다.



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

추가적으로 [에러 핸들링](./error_handling.md) 문서와 [빠르게 시작하기](./quick_start.md) 문서를 참고 해 보기 바란다.




## 클라우드 함수 설치

파이어베이스 클라우드 함수는 대부분 옵션이다. 예를 들면, 회원 탈퇴를 하는 경우 Firebase Auth 계정을 삭제해야하는데, 클라이언트 SDK 에서 하면 다시 로그인을 하라고 물어온다. 이것을 클라우드 함수를 사용하면 사용자에게 물어보지 않고 회원 계정을 삭제 할 수 있는 것이다. 이 처럼 여러가지 클라우드 함수가 있는데, 필요에 따라 설치를 하면 된다.

참고로, 클라우드 함수는 플러터에서만 쓸 수 있는 것이 아니라, 다른 프론트엔드 플랫폼에서도 쓸 수 있다.

참고로, 어떤 푸시 함수는 설치만 하면 동작하는 것이 있으며 또 어떤 것은 클라이언트에서 호출 해 주어야 하는 것이 있다. 특히, http tirgger 함수나 callable 함수는 클라이언트에서 호출을 해 주어야 한다고 생각을 하면 된다.


### 클라우드 함수 설정

`./firebase/functions/src/config.ts` 에 보면 Config 클래스의 `region` 변수가 있다. 이 변수에 원하는 cloud function region 을 기록하면 된다. 그 외에는 특별히 수정을 하지 않아도 된다.





### 전체 클라우드 함수 설치하기

```sh
cd firebase
firebase use --add
firebase deploy --only functions
```

### 필요한 클라우드 함수만 설치하기


#### 푸시 알림 함수

푸시 알림 함수에는 여러 가지 함수가 있다.


- `sendPushNotifications` 함수는 클라이언트에서 여러 개의 푸시 알림 토큰을 서버로 전달해서, 서버에서 푸시 알림을 보낼 수 있게 해 준다.
  - 설치는 그냥 일반적인 클라우드 함수 설치 방식인 `firebase deploy --only functions:sendPushNotifications` 와 같이 하면 된다. 이 후, 다른 클라우드 함수들의 설치도 이와 같아서 생략한다.
  - 참고로 이 함수는 http trigger 함수이다. Restful API 방식으로 호출한다고 생각하면 된다.

- `userMirror` 함수는 사용자의 정보를 Firestore 로 저장하는 함수이다. 기본적으로 사용자 정보는 RTDB 의 `/users` 에 저장되는데, 이 정보를 Firestore 의 `/users` 로 복사하기 위한 것이다. Firestore 로 복사하면 회원 정보 필터링을 보다 상세하게 할 수 있으며 필요에 따라 Firebase Extensions 를 활용하여 여러가지 추가 작업을 할 수 있다.

- `postMirror` 함수는 `userMirror` 함수와 비슷하게 RTDB 의 `/posts` 의 글 정보를 Firestore 의 `/posts` 컬렉션으로 복사한다.

- `commentMirror` 함수는 `userMirror` 함수와 비슷하게 RTDB 의 `/comments` 의 글 정보를 Firestore 의 `/comments` 컬렉션으로 복사한다.

- `mirrorBackfillRtdbToFirestore` 함수는 `userMirror`, `postMirror`, `commentMirror` 를 사용 할 때, 기존의 mirror 되지 않은 데이터를 모두 mirror 하는 것이다. 이 함수는 callable function 이며 관리자만 실행하는 한 함수이다.


- `userLike` 함수는 좋아요 관련 추가 작업을 해 준다. 예를 들어 A 가 B 를 좋아요 하면 A 가 B 를 좋아요 했다는 표시 뿐만아니라 좋아요 갯 수 증/감, 푸시 알림 등 추가적인 작업을 하고자 할 때 이 함수를 쓰면 된다.

- `userDeleteAccount` 는 회원 계정을 Firebase Auth 에서 삭제한다. 클라이언트 SDK 에서 Firebase Auth 를 삭제하려면 recent auth 에러를 내고 다시 로그인하라고 하는데, 이 함수를 사용하면 곧 바로 Firebase Auth 계정을 삭제 할 수 있다.
  - 이 클라우드 함수는 callable function 이다.


- `managePostsSummary` 함수는 글을 RTDB 의 `post-summaries` 와  `post-all-summaries` 에 간추려 저장한다. 기본적으로 `posts` 에 저장되는 글은 여러가지 정보를 추가로 저장하는데, 코멘트까지 같이 저장하므로 글의 용량이 클 수 있다. 그래서 각종 글 관련 목록을 할 때 다운로드해야 하는 양이 많아 비용이 증가 할 수 있는데, 이를 방지하고자 제목, 글쓴이 정도의 간단한 정보만 따로 저장하는 것이다.

- `sendMessagesToCategorySubscribers` 함수는 게시판 (카테고리) 구독자에게 푸시 알림을 전송하고자 할 때 사용하는 함수이다.


- `sendMessagesToChatRoomSubscribers` 함수는 채팅 방에 있는 사용자들 중 푸시 알림 구독자들에게만 푸시 알림을 보내고자 할 때 사용하는 함수이다.

- `link` 함수는 dynamic link 함수이다. 앱을 공유하고자 할 때 사용하는 함수이다.




## Dynamic Link 설치

Dynamic link 란 앱을 공유(다른 사람에게 알려주기 위해)하고자 할 때 특정 링크를 생성해 다른 사용자에게 전달 해 주고, 그 사용자가 링크를 클릭하면 앱애 설치되어져 있으면 앱을 열고, 설치되어져 있지 않으면 Appstore 또는 Playstore 또는 홈페이지를 여는 것이다.

Firebase 에서 제공하던 기존 Dynamic link 도 좀 복잡한 편이었으며 다른 dynamic link 서비스를 쓴다고 해도 딱 그 만큼 복잡하다. 자세한 설명을 위해서는 [다이나믹 링크](./dynamic_link.md) 문서를 참고한다.




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
