# Extensions



## String extensions

You can use `orAnonymousUrl`, `orWhiteUrl`, `orBlackUrl` to display anonymous, or white, black iamge when the string of the url is empty string.

```dart
Avatar(
    photoUrl: my!.photoUrl.orAnonymousUrl,
),
```