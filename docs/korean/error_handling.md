# 에러 핸들링

앱을 개발하면서 여러가지 형태의 에러(Exception)이 발생하게 됩니다. 그리고 Fireflutter 에서 제공하는 위젯 또는 로직에서 FireFlutterException 을 발생 시키기도 합니다. 이러한 Exception 들에 핸들링을 해 주어야하는데, 때로는 필요한 곳에서 적절히 핸들링되지 못하는 경우가 종종 발생합니다. 이렇게 핸들링되지 않은 Exception 들을 모아서, `runZoneGuarded` 방식으로 관리를 하면 됩니다. 이렇게 에러를 핸들링하는 방법은 FireFlutter 를 사용할 때, 권장하는 방법입니다. 다만, 가능하면 에러는 적절한 곳에서 핸들링하는 것이 좋겠습니다.

아래의 예제는 GlobalKey 에 BuildContext 를 담아서 쓰는 예제이다.

예제

```dart
import 'dart:async';
import 'package:example/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 글로벌 키
final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
BuildContext get globalContext => navigatorKey.currentState!.overlay!.context;

void main() async {
  /// Uncaught Exception 핸들링
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      runApp(const MyApp());

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
      };
    },
    zoneErrorHandler,
  );
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
      debugShowCheckedModeBanner: false,
      theme: defaultLightTheme(context: context),
      navigatorKey: navigatorKey,
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
        title: const Text('FireFlutter Quick Start App'),
      ),
      body: Column(
        children: [
          AuthReady(
            builder: (uid) => Column(
              children: [
                Text('UID: $uid'),
                ElevatedButton(
                  onPressed: () => UserService.instance.signOut(),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
            notLoginBuilder: () => Theme(
              data: bigElevatedButtonTheme(context),
              child: const SimpleEmailPasswordLoginForm(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 에러 핸들러
zoneErrorHandler(e, stackTrace) {
  print("----> runZoneGuarded() : Exceptions outside flutter framework.");
  print("--------------------------------------------------------------");
  print("---> runtimeType: ${e.runtimeType}");

  if (e is FirebaseAuthException) {
    String message = "${e.code} - ${e.message}";
    if (e.code == 'invalid-email') {
      message = '잘못된 이메일 주소입니다.';
    } else if (e.code == 'weak-password') {
      message = '비밀번호를 더 어렵게 해 주세요. 대소문자, 숫자 및 특수문자를 포함하여 6자 이상으로 입력해주세요.';
    } else if (e.code == 'email-already-in-use') {
      message = '메일 주소 또는 비밀번호를 잘못 입력하였습니다.';
    }
    toast(context: globalContext, message: '로그인 에러 :  $message');
  } else if (e is FirebaseException) {
    print("FirebaseException :  ${e.code}, ${e.message}");
    if (e.plugin == 'firebase_storage') {
      if (e.code == 'unknown') {
        error(
            context: globalContext,
            message: '파일 업로드 에러 :  ${e.message}\n\nStorage 서비스를 확인해주세요.');
      } else {
        error(context: globalContext, message: e.toString());
      }
    } else {
      error(context: globalContext, message: e.toString());
    }
  } else if (e is FireFlutterException) {
    print("FireshipException: (${e.code}) - ${e.message}");
    if (e.code == 'input-email') {
      error(context: globalContext, message: '이메일 주소를 입력해주세요.');
    } else if (e.code == 'input-password') {
      error(context: globalContext, message: '비밀번호를 입력해주세요.');
    } else {
      error(context: globalContext, title: e.code, message: e.message);
    }
  } else {
    print("Unknown Error :  $e");
    error(context: globalContext, message: e.toString());
  }
  debugPrintStack(stackTrace: stackTrace);
}
```
