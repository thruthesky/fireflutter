# Table of Contents

<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Table of Contents](#table-of-contents)
- [Database](#database)
  - [Get/Set/Update/Toggle](#getsetupdatetoggle)
  - [Database widget](#database-widget)
  - [DatabaseCount widget](#databasecount-widget)

<!-- /code_chunk_output -->



# Database

## Get/Set/Update/Toggle

We have a handy function in `functions/database.dart` to `get, set, update, toogle` the node data from/to firebase realtime database.

- `get('path')` gets the node data of the path from database.
- `set('path', data)` sets the data at the node of the path into database.
- `update('path', { data })` updates the node of the path. The value must be a `Map`.
- `toggle('path')` switches on/off the value of the node. If the node of the [path] does not exist, create it and return true. Or if the node exists, then remove it and return false.

***Note:*** These functions may arise an exception if the security rules are not properly set on the paths. You need to set the security rules by yourself. When you meet an error like `[firebase_database/permission-denied] Client doesn't have permission to access the desired data.`, then check the security rules.

Example of `get()`

```dart
final value = await get('users/15ZXRtt5I2Vr2xo5SJBjAVWaZ0V2');
print('value; $value');
print('value; ${User.fromJson(Map<String, dynamic>.from(value))}');
```

Example of `set()` and `update()`

```dart
String path = 'tmp/a/b/c';
await set(path, 'hello');
print(await get(path));

await update(path, {'k': 'hello', 'v': 'world'});
print(await get(path));
```



`toggle` are responsible to setting `block`, `likes`, `feeds` setting to `true`, following the format `uid: true`. Use this by specifying the path on its parameter. Follow the example below

```dart
final blocked = await toggle(pathBlock(user.uid));
```

Example of `Database` and `toggle`. By default the all the chat rooms are enabled. And if there is a field `disableNotification` with `true`, then it is turned off.

```dart
String get messagingPath => '/chat-rooms/$myUid/$otherUid/disableNotification';
Database(
  path: messagingPath,
  builder: (value, path) => IconButton(
    icon: FaIcon(
      value == true ? FontAwesomeIcons.thinBellSlash : FontAwesomeIcons.thinBell,
    ),
    onPressed: () {
      toggle(messagingPath);
    },
  ),
),
```




## Database widget

`Database` widget rebuilds the widget when the node is changed. Becareful to use the narrowest path of the node or it would download a lot of data.

Consider looking at the `../lib/src/functions/ref.dart`. This provides path from Firestore and Real Time Database.

```dart
// Displaying a Text value
Database(
  path: 'tmp/a/b/c',
  builder: (value) => Text('value: $value'),
),

// Displaying a Text widget with dynamic text.
Database(
  path: pathBlock(post.uid),
  builder: (value, path) => Text(value == null ? tr.block : tr.unblock),
),

// Displaying a toggle IconButton.
Database(
  path: pathPostLikedBy(post.id),
  builder: (v, p) => IconButton(
    onPressed: () => toggle(p),
    icon: Icon(v != null ? Icons.thumb_up : Icons.thumb_up_outlined),
  ),
),
```

## DatabaseCount widget

With database count widget, you may display no of views like below.

```dart
DatabaseCount(
  path: 'posts/${post.id}/seenBy',
  builder: (n) => n == 0 ? const SizedBox.shrink() : Text("No of views $n"),
),
```

where you would code like below if you don't want use database count widget.

```dart
FutureBuilder(
  future: get('posts/${post.id}/seenBy'),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
    if (snapshot.hasError) return Text('Error: ${snapshot.error}');

    if (snapshot.data is! Map) return const SizedBox.shrink();

    int no = (snapshot.data as Map).keys.length;
    if (no == 0) {
      return const SizedBox.shrink();
    }

    return Text("No of views ${(snapshot.data as Map).keys.length}");
  },
),
```
