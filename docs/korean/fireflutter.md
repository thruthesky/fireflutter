# FireFlutter 설정



## global context 적용

때로는 FireFlutter 에서 context 가 필요한 경우가 있다. 예를 들면, FireFlutter 의 `toast` 함수를 사용하며 `snackbar` 를 화면에 표시 할 때, 페이지가 바뀌면 (바뀌기 전 페이지의) context 가 사라지게 되어 `snackbar` 를 닫을 수 없는 상황이 발생한다. 이 경우, global context 를 FireFlutter 에 적용하면 페이지가 바뀌어도 `snackbar` 를 닫을 수 있다. 참고로 FireFlutter 에 global context 를 적용하는 옵션이지만, 가능하면 해 주는 것이 좋다.

아래의 예제는 go_router 를 사용하는데, router 의 context 를 `FireFlutterService.instnace.init(globalContext: ...)` 로 전달하고 있다.


### Navigator 의 context 를 적용하기

- 아래의 예제(`example/lib/main.global_context.ts`)는 global key 를 통해서 FireFlutter 에 global context 를 적용하고 있다. 만약, global context 를 적용하지 않는다면, home page 에서 snackbar 를 표시하고, second page 로 이동한 다음, snackbar 를 닫으려면 에러가 난다.


```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FireFlutterService.instance.init(
        globalContext: () => navigatorKey.currentContext!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              toast(context: context, message: 'Hello, there!');
            },
            child: const Text('Hello, FireFlutter!'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SecondScreen(),
                ),
              );
            },
            child: const Text('Go to second screen!'),
          ),
        ],
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('Second screen!'),
      ),
    );
  }
}
```

### go_router 의 context 를 적용하기

예제: go_router 의 Router 를 정의

```dart
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();

final router = GoRouter(
  navigatorKey: globalNavigatorKey,
  // ...
);
```


에제: global context(navator state context)를 FireFlutter 에 전달하는 예제

```dart
void main() {
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FireFlutterService.instance.init(
          globalContext: () =>
              router.routerDelegate.navigatorKey.currentContext!);
    });
  }
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
```


