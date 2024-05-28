# 언어 번역

기본적으로 FireFlutter 는 영어를 표현하지만, 원하는 언어로 바꾸어 쓸 수 있다. 또한 FireFlutter 에서 제공하는 언어 설정 루틴을 바탕으로 개발하는 앱의 설정을 변경 할 수도 있다.


## Changing the texts

You can change it inside your app.

For instance, simply set the text code as following.

```dart
TextService.instance.texts['name'] = '이름';
TextService.instance.texts[Code.profileUpdate] = '프로필 수정';
```

To know the whole list of text code, you may open `lib/src/text/text.service.dart`.

You may add your own text code and text for your app. So, you don't have to maintain another multi-lingual logic.

For instance, define your own text code for your app like below

```dart
TextService.instance.texts['appName'] = 'My App';
```

And use it when you need,

```dart
Text('appName').tr
```

If the key is not defined in `texts` variable inside `text.service.dart`, then it will be shown as it is.

## Pre-defined texts

Some texts are predefined in `src/text/texts.dart` and you can use it like below.

```dart
Text(T.setting.tr)
```

Note that, `T.setting` is not defined in `texts`. So it is used as it is.

## 다국어 지원

아래와 같이 장치의 기본 언어에 따라 번역된 문자열(문장)을 화면에 보여 줄 수 있다.

번역된 문자열 설정하는 방법

```dart
initTextService(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    TextService.instance.texts = {
        ...TextService.instance.texts,
        if (locale.languageCode == 'ko') ...{
        T.save: '저장',
        T.login: '로그인',
        'phoneSignIn': '전화번호로 로그인',
        },
        if (locale.languageCode == 'en') ...{
        T.save: 'Save',
        T.saved: 'Saved',
        'phoneSignIn': 'Sign in with phone',
        },
        if (locale.languageCode == 'vi') ...{
        T.save: 'Lưu',
        'phoneSignIn': 'Đăng nhập bằng số điện thoại',
        },
        if (locale.languageCode == 'th') ...{
        T.save: 'บันทึก',
        },
        if (locale.languageCode == 'lo') ...{
        T.save: 'ບັນທຶກ',
        },
        if (locale.languageCode == 'my') ...{
        T.save: 'သိမ်းဆည်း',
        }
    };
}
```


## 언어 설정

일반적으로 언어 설정을 할 때, build context 가 필요한데, HomeScreen 과 같은 곳에서 1 회만 호출되도록 하면 된다.

```dart
class HomeScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        initTextService(context: context);
    }
    // 1 회만 언어 설정하도록, 변수(플래그) 설정.
    bool _languageSet = false;
    void initTextService({required BuildContext context}) async {
        if (_languageSet) return;
        _languageSet = true;
        // 기타 언어 설정...
    }
}
```



## 사용하는 방법

```dart
'phoneSignIn'.tr
```






## 새로운 언어 설정 및 번역 기능 - version 0.3.32

- 버전 0.3.31 이전의 문제점은 FireFlutter 가 기본적으로 영어만 제공한다는 것이다. 그래서 앱을 개발 할 때 한글 및 다른 언어를 일일히 번역을 해 주어야 하는 불편함이 있었다. 하지만, 버전 0.3.32 부터는 기본적으로 영어와 한글 두 가지를 지원하며, 얼마든지 쉽게, 더 많이 언어를 추가할 수 있도록 변경을 했다.

- 기본적인 사용 방법은 아래와 같다. 아무런 초기화 없이 그냥 쓰면 기본적으로 영어로 된다.

```dart
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Text(T.version.tr);
  }
}
```

- 아래와 같이 초기화를 할 수 있다.
    - `TextService.instance.init(languageCode: ... )` 에 원하는 언어 코드를 소문자 두 글자로 지정하면 된다. 예를 들면 `en`, `ko` 와 같이 하면 된다.
    - 참고로 `replace` 는 FireFlutter 가 제공하는 것으로 번역 텍스트에 있는 문자열을 변경해 준다.


```dart
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    TextService.instance.init(languageCode: 'ko');
  }

  @override
  Widget build(BuildContext context) {
    return Text(T.version.tr.replace({'#version': '1.0.0'}));
  }
}
```

- 번역 문자열은 `lib/src/texts.dart` 에 있으며, 번역 문자열은 아래와 같이 추가(또는 수정)하면 된다.
    - 만약, 아래에 추가되지 않은 문자열은 기본적으로 영어로 표시한다. 예를 들어 `TextService.instance.init(languageCode: 'ja')` 와 같이 했는데, 아래에 와 같이 `ja` 텍스트 값이 지정되지 않았다면 `en` 의 값을 기본적으로 사용한다.

```dart
static const Mintl version = {
'en': 'Ver: #version',
'ko': '버전: #version',
};
```

- 아래와 같이 `T.version.tr.replace` 대신 보다 짧게 `T.version.args` 를 쓸 수 있다. 단순히 짧게 쓰는 역할만 한다. `args` 함수를 쓸 때에는 맵의 키에 `#` 를 붙여 줄 필요 없다. 자동으로 `#` 을 붙여서 치환해 준다.

```dart
T.version.args({'version': '1.0.0'})
```

- 동적으로 언어 변경을 할 수 있다. 아래와 같이 처음에는 languageCode 를 `ch` 로 했다가 언제든지 원한다면 다른 언어 코드로 변경을 할 수 있다.

```dart
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    TextService.instance.init(languageCode: 'ch');
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
    return Text({'ja': '私のバージョン: #version'}.args({'version': '1.0.0'}));
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




- 만약, FireFlutter 에서 제공하는 기본 언어 번역이 마음에 들지 않는다면, 아래와 같이 변경 할 수 있다.

```dart
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    TextService.instance.languageCode = 'ko';
    T.version = {
      'en': 'New Version #version',
      'ko': '새 버전 #version',
    };
    return Text(T.version.args({'version': '1.0.0'}));
  }
}
```


- 좀 더 많은 활용을 하자면 아래와 같이 할 수도 있다.

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