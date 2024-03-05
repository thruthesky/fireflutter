# Widgets

This section provides an explanation of the basic widgets provided by Fireship.

@TODO @thruthesky Refer to the pub.dev API reference and explain how to use the widgets listed there.

## LabelField

It is designed to make TextField usage more convenient.

## UpdateBirthday

To display and allow users to edit their birthdate information on pages like the profile editing page, you can use the `UpdateBirthday` widget. It allows you to provide labels and descriptions.

Example:

```dart
UpdateBirthday(
    label: '생년월일',
    description: '본인 인증에 사용되므로 올바른 생년/월/일 정보를 선택해 주세요.',
)
```

## DisplayPhotos - Displaying Photos

When you pass an array of URLs, it displays the photos on the screen.

```dart
DisplayPhotos(urls: List<String>.from(v ?? []))
```

## Displaying Users

To display users in tile format, you can use the `UserTile`. If you have a user model, you can display it like `UserTile(user: UserModel)`. If you only have the user ID, you can call `UserTile.fromUid(uid)`.

## Displaying User Information

When displaying user information, including the logged-in user, you can use `UserDoc`.

UserDoc can be utilized in the following ways:

- Fetching user documents and displaying them on the screen
- Updating user documents in real-time to display them on the screen. Rebuilding if the value in the database changes.
- Displaying a specific field from the user document on the screen
- Updating a specific field from the user document in real-time to display it on the screen. Rebuilding if the value in the database changes.

Example

```dart
UserDoc(uid: myUid!, builder: (user) => Text(user.displayName)),
UserDoc.sync(uid: myUid!, builder: (user) => Text(user.displayName)),
UserDoc.field(uid: myUid!, field: 'displayName', builder: (v) => Text(v.toString())),
UserDoc.fieldSync(uid: myUid!, field: 'displayName',  builder: (v) => Text(v.toString())),
```

By the way, in cases where data is not displayed in real-time, you can cache the data in memory using `cacheId` and then quickly display it on the screen. This can be particularly useful in scenarios where you call setState to reduce screen flickering.

Example - Using cacheId

```dart
UserDisplayName(uid: uid, cacheId: 'chatRoom'),
```

## User Cache

Sometimes, after displaying user information and calling setState, the screen may flicker. Or you may not prefer continuously accessing the database. In such cases, using cacheId allows you to cache the value (or field) of the user at that cacheId location in memory.

```dart
UserDoc(cacheId: 'home');
```

Alternatively,

```dart
UserDoc.field(
    cacheId: cacheId,
    uid: uid,
    field: Field.displayName,
    builder: (data) => Text(
      data
    ),
  );
```

/// UserDoc( ... )
/// UserDoc.sync(uid: user.uid, field: 'displayName', builder: (data, $) => Text(data)),
/// UserDoc.field( ... )
/// UserDoc.fieldSync( ...)

## Displaying User Name

Example

```dart
 UserDisplayName(
  uid: userUid,
  user: user,
),
```

Example - You can use sync for real-time updates.

```dart
 UserDisplayName.sync(
  uid: userUid,
  user: user,
),
```

## Displaying User Photo

Example - Displaying User Photo

```dart
UserAvatar(uid: userUid, size: 100, radius: 40),
```

Example - Displaying User Photo with Real-time Updates

## Displaying User Background Photo

You can simply display it as follows.

```dart
UserBackgroundImage(
  uid: userUid,
  user: user,
),
```

If real-time update is needed, you can do as follows.

```dart
UserBackgroundImage.sync(
  uid: userUid,
  user: user,
),
```

## Displaying user status message

Example

```dart
UserStateMessage(uid: ..., user: user),
```

Example - Real-time update via sync

```dart
UserStateMessage.sync(
  uid: userUid,
  user: user,
),
```

## Buttons

This section explains various types of buttons. If you don't like the design, you can copy the source code and modify it to suit your needs.

### Like Button

```dart
LikeButton(uid: userUid, user: user),
```

### Bookmark Button

```dart
BookmarkButton(uid: userUid),
```

### Chat Button

```dart
ChatButton(uid: uid),
```

### Report Button

The report button can be used to report users, posts, comments, and chats.

Example - Reporting a User

```dart
ReportButton(uid: userUid),
```

### Block Button

```dart
BlockButton(uid: userUid),
```
