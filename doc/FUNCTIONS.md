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

## timeago

Returns a string of human readable time ago string. It supports i18n. See [**timeago**](#timeago) above.

## getYoutubeIdFromUrl

Returns the Youtube ID of a URL

<!-- Use this method to get youtube id from the youtube url. -->

```dart
onTap: () {
  String? result = getYoutube("url");
  setState(() {
    ytId = result ?? 'url has no ID';
  });
},
```

## getYoutubeThumbnail

Returns the url of Youtube Thumbnail from ID

<!-- Use this method to get the YouTube video's thumbnail from the yotube id. -->

```dart
onTap: () {
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
},
```

<!-- TODO:
  - post returns an int
  - getter iLiked is gone or replaced [???]
  - relearn
 -->
