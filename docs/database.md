# Database

Fireship uses `Firebase Realtime Database`, although the majority of developers use `Firestore`. We have chosen the realtime database because it's fast and simple. You may use `Firestore` together with Fireship.

## Gudeline

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
