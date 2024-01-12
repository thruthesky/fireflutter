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
