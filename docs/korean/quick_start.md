# 빠르게 시작하기

본 문서는 FireFlutter 를 가장 빠르게 익힐 수 있는 지름길을 제공한다. 물론 가능하ㅁ녀 FireFlutter 의 모든 문서를 읽어 보기를 권한다.

## FireFlutter 를 사용하는 가장 간단한 앱 만들기

- 아래의 코드는 FireFlutter 패키지를 사용하는 가장 간단한 예제 이다.

```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => alert(
            context: context,
            title: 'Hello, there!',
            message: 'This is the simplest FireFlutter app.',
          ),
          child: const Text('Hello, FireFlutter!'),
        ),
      ),
    ),
  );
}
```

## FireFlutter 에 global context 적용하기

- [FireFlutter 문서](./fireflutter.md)를 참고한다.



## 간단한 로그인 및 회원 정보 수정

아래는 간단한 이메일 회원 가입 및 로그인, 그리고 회원 정보 수정을 화면에 표시하는 예제이다.
참고로 FireFlutter 에서 로그인과 관련된 몇 몇 위젯을 제공한다. 하지만 FireFlutter 가 제공하는 기본 로그인 위젯에 얽매이지 말고, 개발자가 직접 원하는데로 커스텀 UI/UX 를 만들어서 로그인을 하면 된다. 어떻게든 Firebase Auth 에 로그인만 하고, `UserService.instance.login()` 만 한번 호출 해 주면, FireFlutter 가 잘 동작한다.

아래의 소스 코드를 설명하자면,

- 먼저, Firebase 를 Flutter 앱과 연결한다. `flutterfire CLI` 로 하시거나 수동으로 하면 된다.
- 그리고 `fireflutter` 패키지를 pubspec.yaml 에 추가한다.
- 그리고 `main()` 에서 Firebase 초기화한다.
- 그리고 `UserService.instance.init()` 을 통해서 사용자 기능을 활성화한다.
- 그리고, `Login` 위젯을 통해서 사용자가 Firebase 에 로그인을 했는지 안했는지 알 수 있다.
- 아래의 예제에서는 로그인을 하지 않았으면, `SimpleEmailPasswordLoginForm` 위젯을 표시하여 회원 가입 또는 로그인을 하도록 한다.

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

### 구글 전화 로그인

`SimpleEmailPasswordLoginForm` 대신 `SimplePhoneSignInForm` 을 사용해서, 구글 전화 로그인을 할 수 있다.

`SimplePhoneSignInForm` 에 대한 자세한 설명은 [widget 문서](./widgets.md)를 참고한다.


## 회원 정보 수정

회원 정보 수정 화면은 이름, 성별, 생년월일 등을 수정할 수 있는 화면이다. 회원 정보 수정 화면은 앱 내의 다양한 위치에서 호출 될 수 있는데, 편리하게 사용하기 위해서 `UserService.instance.showProfileUpdateScreen()` 을 호출하면 회원 정보 수정 화면이 보이도록 해 놓았다. 회원 정보 수정 화면을 열어야 할 필요가 있을 때 마다 이 함수를 호출하면 된다.

커스텀 디자인을 하려면 크게 두 가지 방법으로 할 수 있는데, 보다 자세한 정보는 [사용자 문서](./user.md)를 참고하기 바란다.


## 공개 프로필

공개 프로필은 `UserService.instance.showPublicProfileScreen()` 을 호출하면 된다.
커스텀 디자인을 하려면 크게 두 가지 방법으로 할 수 있는데, 보다 자세한 정보는 [사용자 문서](./user.md)를 참고하기 바란다.


## 로그인 사용자 프로필 스티커

`MyProfileSticker` 를 통해서 로그인한 사용자 정보를 한 줄 짜리 스티커형 배너를 표시 할 수 있다.


## global context 적용

FireFlutter 에 global build context 를 적용하는 것이 좋다. 자세한 내용은 [FireFlutter 문서](./fireflutter.md#global-context-적용)를 참고한다.



## 에러 메시지 핸들링

FireFlutter 에서 Exception 을 발생하는 경우가 있다. 플러터에서는 `runZonedGuarded` 를 통해서, 앱내에서 발생하는 여러 exception 을 화면에 표시 할 수 있는데, 이것을 활용해서 FireFlutter 가 발생시키는 FireFlutterException 에러를 사용자에게 표시 할 수 있다.

```dart
zoneErrorHandler(e, stackTrace) {
  dog("---> zoneErrorHandler; runtimeType: ${e.runtimeType}");
  if (e is FirebaseAuthException) {
    toast(
        context: globalContext,
        message: '로그인 관련 에러 :  ${e.code} - ${e.message}');
  } else if (e is FirebaseException) {
    dog("FirebaseException :  $e }");
  } else if (e is FireFlutterException) {
    dog("FireFlutterException: (${e.code}) - ${e.message}");
    error(context: globalContext, message: e.message);
  } else {
    dog("Unknown Error :  $e");
  }
  debugPrintStack(stackTrace: stackTrace);
}

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      runApp(const ChatApp());

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
      };
    },
    zoneErrorHandler,
  );
}
```