# User

- [User](#user)
  - [Overview](#overview)
  - [Like](#like)



## Overview

`idVerifiedCode` is the code of user's authentication id code. This is used to save user's id code when the user uploaded his id card like passport and the AI (Firebase AI Extension) detect user's information and the verification succeed, the file path is being hsave in `idVerificationCoce`. You may use it on your own purpose.

`complete` is a boolean field to indicate that the user completed updating his profile information.

`verified` is a boolean field to indicate that the user's identification has fully verified by the system. Note that, this is not secured by the rules as of now. Meaning, user can edit it by himself.

`birthDayOfYear` is the birth day of the year. It is automatically set by the `User.update()`. For instnace, if the user saves his birth day, then the app should use this kind of code; `my.update(birthYear: 1999, birthMonth: 9, birthDay: 9);` and it will automtically update the `birthDayOfYear` value.




## Like

The `likes` data saved under `/likes` in RTDB. Not that, the `likes` for posts and comments are saved inside the documents of the posts and the comments.

See the following example how to display the no of likes of a user and how to increase or decrease the number of the `like`.

Example of text button with like

```dart
TextButton(
  onPressed: () => like(user.uid),
  child: Database(
    path: 'likes/${user.uid}',
    builder: (value) => return Text(value == null ? 'Like' : '${(value as Map).length} Likes'),
  )
),
```

Example of icon button with like

```dart
IconButton(
  onPressed: () => like(user.uid),
  icon: Database(
    path: 'likes/${user.uid}',
    builder: (value) => Icon(
      Icons.favorite_border,
      color: value == null ? null : Theme.of(context).colorScheme.tertiary,
    ),
  ),
),
```
