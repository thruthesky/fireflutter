# FireFlutter 설정



## global context 적용

아래의 예제를 보면, router 의 context 를 `FireFlutterService.instnace.init(globalContext: ...)` 로 전달하고 있다. 이렇게 하는 이유는 하위 페이지에서 `toast` 와 같은 함수를 호출하여 snackbar 를 표현 할 때, context 가 바뀔 때, 닫기 버튼이 동작하지 않는 경우가 발생한다. Global build context 를 설정하면, 페이지가 바뀌어도 스낵바의 닫기 버튼 등이 잘 동작한다.

참고로 이것은 옵션이지만, 가능하면 해 주는 것이 좋다.


예제 - global context(navator state context)를 FireFlutter 에 전달

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


예제 - go_router 를 사용하는 경우

```dart
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();

final router = GoRouter(
  navigatorKey: globalNavigatorKey,
  // ...
);
```