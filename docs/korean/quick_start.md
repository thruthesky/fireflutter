# 빠르게 시작하기


## 간단한 로그인 및 회원 정보 수정

아래는 간단한 이메일 회원 가입 및 로그인, 그리고 회원 정보 수정을 화면에 표시하는 예제이다.

- 먼저, Firebase 를 Flutter 앱과 연결한다.
- 그리고 Firebase 초기화를 한다.
- 그리고 `UserService.instance.init()` 을 통해서 사용자 기능을 활성화 한다.
- 그리고 `MaterialApp(theme: defaultLightTheme())` 을 적용한다. 만약, 아무런 테마를 지정하지 않으면 기본 Material UI 디자인이 화면에 나타난다. `defaultLightTheme()` 함수를 복사해서 자신만의 테마 설정을 해도 된다.
- 그리고, `AuthReady()` 를 통해서 사용자가 Firebase 에 로그인을 했는지 안했는지 알 수 있다.

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
    return MaterialApp(
      theme: defaultLightTheme(context: context),
      home: const MyHomePage(),
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FireFlutter Demo'),
      ),
      body: Column(
        children: [
          AuthReady(
            builder: (uid) => Column(
              children: [
                Text('UID: $uid'),
                ElevatedButton(
                  onPressed: () =>
                      UserService.instance.showProfileUpdateScreen(context),
                  child: const Text('Profile'),
                )
              ],
            ),
            notLogin: Theme(
              data: bigButtonTheme(context),
              child: const SimpleEmailPasswordLoginForm(),
            ),
          ),
        ],
      ),
    );
  }
}
```