# Translation

The default language is English. And you can chagne it into different language or change it into your own texts.


## Changing the texts

You can change it inside your app.

For instance, simply set the text code as following.

```dart
TextService.instance.texts['name'] = '이름';
```


To know the whole list of text code, you may open `lib/src/translation/translation.service.dart`.



You may add your own text code and translation for your app. So, you don't have to maintain another multi-lingual logic.

For instance, define your own text code for your app like below

```dart
TextService.instance.texts['appName'] = 'My App';
```

And use it when you need,

```dart
Text('appName').tr
```
