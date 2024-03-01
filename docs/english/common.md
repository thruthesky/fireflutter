# Common

These will be commonly used in different aspect of the app.

## Widgets

### Avatar

Displays like an avatar when a photo URL is provided.

```dart
Avatar(photoUrl: room.photoUrl);
```

Parameters:

- double size
  - The size of the avatar [default] 48.
- double radius
  - The radius of the borders of the avatar [default] 20.
- String photoUrl
  - Required URL of the photo in the avatar

The url doesn't have to be a user's avatar. It can be used in any photo URLs.

We can also use `anonymousUrl`, a photo for anonymous picture.

```dart
import 'package:fireflutter/fireflutter.dart';
...
// Note that this is a different approach from AnonymousAvatar Widget
Avatar(photoUrl: anonymousUrl);
```

When we want to use Avatar for a User's Profile Photo, it is recommended to use UserAvatar instead. See [user.md doc](user.md).

### AnonymousAvatar

익명 사용자를 나타낼 때 사용하는 아바타 (Used for representing anonymous users).

```dart
AnonymousAvatar(text: 'G');
```

Parameters:

- double size
  - The size of the avatar
- double radius
  - The radius of the borders of the avatar
- String? text
  - The initial character of the anonymous avatar

### StackedAvatar

스택으로 여러 아바타를 표시 (Displays multiple avatars in a stack)

<!-- TODO Example -->

## LinkifyText

- Easy to link urls in the text.

<!-- TODO Example -->
