# 언어 번역

- 2024년 6월 FireFlutter 는 영어와 한글을 지원한다. 원한다면 `lib/src/texts.dart` 에 언어를 추가할 수 있다.



## 언어 설정 초기화

- 아래와 같이 앱이 시작되는 시점에서 초기화를 하면 된다.
- 아래의 코드를 보면 먼저 `TextService.instance.init( languageCode: 'ko' );` 와 같이 지정을 하는데, 이렇게 하는 이유는
  - 한글로 표시하고 싶은데,
  - 기본 언어가 영어이므로, 화면에 먼저 영어로 표시되고, `scheduleMicrotask()` 에 의해서 언어가 설정된 후, 한글이 보인다.
  - 즉, 먼저 영어가 표시되고 한글로 바뀌는 현상이 나타나는데,
  - 처음 부터 한글로 정해 주고, 혹시나 핸드폰의 언어가 한글이 아닌 경우, 해당 언어로 보여주기 위한 것이다.

```dart
class _MyAppState extends State<PhiLovApp> {
  @override
  void initState() {

    TextService.instance.init( languageCode: 'ko' );

    scheduleMicrotask(() {
      TextService.instance.init(
        languageCode: Localizations.localeOf(globalContext).languageCode,
      );
    });
  }
}
```


## 언어 변경

- Fireflutter 에서 제공하는 번역 언어가 마음에 안드는 경우, 아래와 같이 단순히 대입을 해서 수정하면 된다.

```dart
T.version = {
  'en': 'Ver. #version',
  'ko': '번호. #version',
};
Text(T.version.args({'version': '1.0.0'})),
```

어떤 번역이 있는지 알고 싶으면, `lib/src/texts.dart` 파일을 참고한다.




## 언어 번역 사용하는 방법

언어 번역 정보는 `T` 클래스의 static 변수에 아래와 같이 저장된다. 참고로, 추가하고 싶은 언어가 있으면 언어 코드를 추가한 다음 PR 하면 된다.

```dart
class T {
  static Json version = {
    'en': 'Ver: #version',
    'ko': '버전: #version',
  };
  static Json yes = {
    'en': 'Yes',
    'ko': '예',
    'vi': 'Có',
    'th': 'ใช่',
    'lo': 'ແມ່ນແລ້ວ'
  };

  // ...
```

위와 같은 경우, `T.yes.tr` 와 같이 하면 된다. 그렇다면 현재 장치의 언어에 따라 번역된 단어를 사용 할 수 있다.

`T.version.tr.replace({'#version': '1.0.0'})` 아래와 같이 값을 치환할 수 있으며, 보다 짧게 `T.version.args` 를 쓸 수 있다. `args` 는 단순히 짧게 쓰는 역할만 한다. `args` 함수를 쓸 때에는 맵의 키에 `#` 를 붙여 줄 필요 없다. 자동으로 `#` 을 붙여서 치환해 준다.

```dart
T.version.args({'version': '1.0.0'})
```

- 동적으로 언어 변경을 할 수 있다. 아래와 같이 처음에는 languageCode 를 `ja` 로 했다가 언제든지 원한다면 다른 언어 코드로 변경을 할 수 있다.

```dart
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    TextService.instance.init(languageCode: 'ja');
  }

  @override
  Widget build(BuildContext context) {
    TextService.instance.init(languageCode: 'ko');
    return Center(child: Text(T.version.args({'version': '1.0.0'})));
  }
```


- 아래와 같이 언어 번역이 어떻게 동작하는지 이해를 하면 매우 편리하게 쓸 수 있다.
    - 현재 사용할 언어 코드를 `TextService.instance.init(languageCode: ...)` 로 하지 않고, 곧 바로 `TextService.instance.languageCode` 변수에 지정했다. 이렇게 해도 동일한 효과를 가진다.
    - 그리고, `T.xxx` 와 같이 FireFlutter 에서 미리 정의된 언어 번역 텍스트가 아니어도 된다. 즉, 앱에서 직접 만들어 쓸 수 있다.

```dart
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    TextService.instance.languageCode = 'ja';
    return Text({'ja': '私のバージョン: #version'}.args({'version': '1.0.0'}));:wq
  }
}
```

- 그리고 위의 아이디어를 활용해서, 앱에서 사용하는 텍스트를 언어 번역할 수 있다. 즉, FireFlutter 의 번역 기능을 활용해서 앱에서 사용하는 텍스트를 번역 할 수 있는 것이다.
    - 참고로, `Mintl` 은 `typedef` 로 정의된 단순한 `Map<String, String>` 타입이다.

```dart
typedef Ty = Map<String, String>;
class At {
  static const Ty home = {
    'en': 'Home',
    'ko': '홈',
  };
}
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    TextService.instance.languageCode = 'ja';
    return Column(
      children: [
        Text(T.version.args({'version': '1.0.0'})),
        Text(At.ver.args({'ver': '1.0.0'})),
      ],
    );
  }
}
```

- 앱 내에서 아래와 같이 Fireflutter 의 번역 기능을 활용할 수 있다.

```dart
import 'package:fireflutter/fireflutter.dart';

class Tr {
  static String home = {
    'en': 'Home',
    'ko': '홈',
  }.tr;
}

print(Tr.home);
```