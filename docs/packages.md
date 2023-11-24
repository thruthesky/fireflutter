
# Packages

In this section, the packages that are used by Flutterflow are explained.

## url_launcher (Optional)

`url_lancher` package is added by fireflutter and it is being used to open url. If you wish to let users share links by sms, you need to setup in `AndroidManifest.xml` and `Info.plist`. See the [url_launch Configuration](https://pub.dev/packages/url_launcher#configuration).

FireFlutter exposes a method `launchSMS` to open the SMS app. Here is an example of how to send sms. You can build your own code, of course.

```dart
final re = await launchSMS(phnumber: '', msg: link);
if (re) {
  toast(title: 'SMS', message: 'Link sent by SMS');
} else {
  toast(title: 'SMS', message: 'Cannot open SMS');
}
```

In this chapter, some of the notable packages that are used by FireFlutter are explained.

# timeago

Converts date into a humanized text.

```dart
    final fifteenAgo = DateTime.now().subtract(Duration(minutes: 15));

    print(timeago.format(fifteenAgo)); // 15 minutes ago
    print(timeago.format(fifteenAgo, locale: 'en_short')); // 15m
    print(timeago.format(fifteenAgo, locale: 'es')); // hace 15 minutos
```

Visit [timeago](https://pub.dev/packages/timeago) to read more.

## Parsed_ReadMore

Allows the text to collapsed or expanded and automatically parse the url text to hyperlinks.

Visit [parsed_readmore](https://pub.dev/packages/parsed_readmore) to read more.

<!-- TODO: -->