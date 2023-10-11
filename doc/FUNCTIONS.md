# Table of Contents


<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [alert](#alert)
- [toast](#toast)
- [warningSnackBar](#warningsnackbar)
- [prompt](#prompt)
- [confirm](#confirm)
- [input](#input)
- [randomString](#randomstring)
- [datetimeAgo](#datetimeago)
- [datetimeShort](#datetimeshort)
- [getYoutubeIdFromUrl](#getyoutubeidfromurl)
- [getYoutubeThumbnail](#getyoutubethumbnail)
- [launchSMS](#launchsms)
- [loginFirstToast](#loginfirsttoast)
- [indent](#indent)
- [platformName](#platformname)
- [sanitizeFilename](#sanitizefilename)

<!-- /code_chunk_output -->


# Functions

Here are some functions that Fireflutter builds for your app. Utilize them to increase your production.  

## alert

Use `alert` method to display a dialog to alert(alarm) the user.

```dart
await alert(
  context: context,
  title: 'Withdrawal',
  message: 'I have canceled my membership.');
```

  <!-- 
  translated into english
  title: '회원 탈퇴',
  message: '회원 탈퇴를 하였습니다.'); -->

## toast

Use `toast` to display a toast notification

```dart
toast(
  icon: const Icon(Icons.link),
  title: url,
  message: 'Open the link?',
  onTap: (p0) => launchUrl(Uri.parse(url)),
);
```

## warningSnackBar

Use `warningSnackbar` to display a warning message

```dart
warningSnackbar(context, 'Warning message');
```

## prompt

Use `prompt` to get a string value from user.

```dart
final password = await prompt(
  context: context,
  title: 'Resign',
  message: 'Please input your password to resign.',
);
```

## confirm
Use `confirm` to ask user for confirmation of the action
```dart
confirm(context: context, title: 'Upload Image', message: 'This image will be seen by others');
```

## input

`input` is an alias of `prompt`.

```dart
onTap: () => input(
  context: context,
  title: 'this is input()',
  message: 'Hello World!',
),
```

## randomString

Returns a random string.

```dart
// randomString() has default length value of 12
// define the length of the String result
int length = 5;
onTap: () {
  String result = randomString(length); // or randomString()
  setState(() {
    text = result;
  });
},
```

## datetimeAgo

Use `datetimeAgo` to get the elapsed time of the post, comment or chats.

```dart
final timeAgo = datetimeAgo(dateTime);
```

## datetimeShort
Use `datetimeShort` to get the simplified value of a date time. This either returns `yyyy-MM-dd` or `HH-mm-ss`.

```dart
String time = dateTimeShort(DateTime.now());
```

## getYoutubeIdFromUrl

Returns the Youtube ID of a URL

<!-- Use this method to get youtube id from the youtube url. -->

```dart
String? result = getYoutube("url");
setState(() {
  ytId = result ?? 'url has no ID';
});
```

## getYoutubeThumbnail

Returns the url of Youtube Thumbnail from ID

<!-- Use this method to get the YouTube video's thumbnail from the yotube id. -->

```dart
// you can use the getYoutubeIdFromUrl() to get the Youtube ID
String? result = getYoutubeIdFromUrl(url);
String thumbNail = getYoutubeThumbnail(
  videoId: result ?? '', // required field
  quality: YoutubeThumbnailQuality.high,
  webp: false,
);
setState(() {
  ytThumbNail = thumbNail;
});
```

## launchSMS
Use `launchSMS` to open the SMS app with the number and message.

```dart
launchSMS(phoneNumber: "0039-999-999-999", msg: "hello there");
```

## loginFirstToast
Use `loginFirstToast` to display snackbar when user is not logged in

```dart
loginFirstToast();
```

## indent
Use `indent` to visually indent the comments reply based on their hierarchy. This has a depth maximum of 6.

```dart
Padding(
  padding: EdgeInsets.only(left: indent(6)), // indent() returns [double]
),
```

## platformName
Use `platformName` to get the current device platform. 
```dart
// it returns 'web', 'android', 'fuchsia', 'ios', 'linux', 'macos', 'windows' as String
platformName(); 
```
## sanitizeFilename
Use `sanitizeFilename` to remove unsafe characters from the files.

```dart
// [replacement] will replace the unsafe characters with its own value
sanitizeFilename('file-name.jpg', replacement='_');
```