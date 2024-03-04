# Extensions



## String extensions

You can use `orAnonymousUrl`, `orWhiteUrl`, `orBlackUrl` to display anonymous, or white, black iamge when the string of the url is empty string.

```dart
Avatar(
    photoUrl: my!.photoUrl.orAnonymousUrl,
),
```



`ifEmpty` and `or` have same fuctionality that if the string is empty, it will use the parameter value. Note that it's not working if the string is null.