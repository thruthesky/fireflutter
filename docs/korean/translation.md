# Text

The default language is English. And you can change it into different language or change it into your own texts.

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
```

## 사용하는 방법

```dart
'phoneSignIn'.tr
```
