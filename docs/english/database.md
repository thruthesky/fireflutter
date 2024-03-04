# Database

FireFlutter uses Realtime Database. Initially, FireFlutter was actively developed and used through Firestore. However, in early 2024, it was determined that Realtime Database could be sufficiently well-implemented, leading to the development of a more concise and faster package. As a result, the package primarily using Realtime Database was developed.

## Database Guidelines

- By using Realtime Database instead of Firestore,
    - You can listen to parts of the data rather than the entire data, and fetch minimal units of data from the database.
    - This allows you to retrieve data faster and display it on the screen more efficiently.
    - It can lead to cost savings.

- Use hyphens (-) instead of underscores (_) in database paths whenever possible.
    - For example, use user-private instead of user_private.

## Database Structure

- Aim for a flat data structure whenever possible.
- Avoid nesting subcollections whenever possible. For instance, refrain from storing comments under a post node. For example,
    - Instead of storing comments under a post like `/posts/<postId>/comments/...`,
    - Store posts under `/posts/<postId>` and comments under `/comments/<postId>/...` to separate the data groups.

## Database Widgets

- Provides widgets for easy database usage.

## Value Widget

The Value widget displays information from the Realtime Database in real-time on the screen. When displaying values from the database on the screen, it is essential to use this widget.

When a database path is specified in `path`, it is passed to the `builder` as dynamic type. If there is no value at the specified path, a null value is passed to the builder.

Providing the same value as in the database to `initialData` significantly reduces screen flickering.

Example 1 - Display the value of the `test/banana` node on the screen.

```dart
Value(
  initialData: 'BANANA',
  path: 'test/banana',
  builder: (v) => Text(v.toString()),
),
```

Example 2 - Display the phone number of the logged-in user on the screen.

```dart
Value(path: Path.phoneNumber, builder: (v) => Text(v ?? ''))
```

You can display a loader icon in onLoading, or show default widgets to reduce screen flickering.

```dart
Database(
  path: post.ref.child(Field.noOfLikes).path,
  builder: (no) => Text('좋아요${likeText(no)}'),
  onLoading: const Text('좋아요'),
),
```

Through `Value.once`, you can display the value only once on the screen. In other words, if the value continues to be modified, it will not be displayed on the screen in real-time. Instead, it fetches the value once, displays it on the screen, and does not update it even if it changes.

```dart
Value.once(
  initialData: 'BANANA',
  path: 'test/banana',
  builder: (v) => Text(v.toString()),
),
```

## User Database

See [user document](user.md).
