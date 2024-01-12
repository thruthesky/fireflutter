# Database

Fireship uses `Firebase Realtime Database`. We have chosen the realtime database because it's fast and simple. You may use `Firestore` together with Fireship.

## Gudeline

- We use `Realtime Database` and it's different from `Firestore`. And it is good to know that the app should
  - listen(observe) as small portion as it can be.
  - get the data as small portion as it can be.
  - not listening the whole document of a user or a post. Just listen a portion of it. Meaning, instead of listing the whole post document, just listen the title only if it's needed.

- The path of database should not contain underbar(\_). Instead use `-` between the words.
  - For instance, `user-profile-photos`.

## Database structure

Fireship maintains as flat as it can be. Meaning, it does not contains a batch of data inside a node. For instance, the data of the users are saved under `/users/<uid>` and its data should not contain another batch of data. The fields should have a value of string, number, array. But not a map or subnode.

Below is the good example of flat style.

```json
/users/<uid>/ { name: ..., age: ..., address: ..., }
```

Below is the bad example because it has other batch of information under the user node.

```json
/users/<uid>/schedule/<scheduleId>/ { subject: ..., contenxt: ...., dateAt: ...}
```

## Use Database

```dart
Database(
    path: '${Path.join(myUid!, chat.room.id)}/name',
    builder: (v, p) => Text(
        v ?? '',
        style: Theme.of(context).textTheme.titleLarge,
    ),
),
```

## User Database

See user document.
