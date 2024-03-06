# 빠르게 시작하기


## 간단한 로그인 및 회원 정보 수정

아래는 간단한 이메일 회원 가입 및 로그인, 그리고 회원 정보 수정을 화면에 표시하는 예제입니다.

- 먼저, Firebase 를 Flutter 앱과 연결합니다. `flutterfire CLI` 로 하시거나 수동으로 하시면 됩니다.
- 그리고 `fireflutter` 패키지를 pubspec.yaml 에 추가합니다.
- 그리고 `main()` 에서 Firebase 초기화를 합니다.
- 그리고 `UserService.instance.init()` 을 통해서 사용자 기능을 활성화 합니다.
- 그리고 `MaterialApp(theme: defaultLightTheme())` 을 적용합니다. 만약, 아무런 테마를 지정하지 않으면 기본 Material UI 디자인이 화면에 나타납니다. `defaultLightTheme()` 함수를 복사해서 자신만의 테마 설정을 해도 됩니다.
- 그리고, `AuthReady()` 를 통해서 사용자가 Firebase 에 로그인을 했는지 안했는지 알 수 있습니다.
- 아래의 예제에서는 로그인을 하지 않았으면, `SimpleEmailPasswordLoginForm` 위젯을 표시하여 회원 가입 또는 로그인을 하도록 합니다.

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