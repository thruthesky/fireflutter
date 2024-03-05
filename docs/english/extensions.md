# Extensions

## String extensions

You can use `orAnonymousUrl`, `orWhiteUrl`, `orBlackUrl` to display anonymous, or white, black iamge when the string of the url is empty string.

```dart
Avatar(
    photoUrl: my!.photoUrl.orAnonymousUrl,
),
```

`ifEmpty` and `or` have same functionality that if the string is empty, it will use the parameter value. Note that it's not working if the string is null.

`upTo` cuts the string to a specific length from the beginning.

`sanitize` removes special characters.

`cut` function cuts a string to a specific length, including cutting any special characters in the middle. It combines both the `upTo` and `sanitize` functions into one.

`isEmail` checks if a string is an email address.

`tryInt` and `tryDouble` convert a string into an integer and a double, respectively. If the conversion fails, they return null.

`replace` takes a map of data and replaces all occurrences of the data in the string.
