# 데이터베이스

FireFlutter에서는 Realtime Database를 사용합니다. 초기에는 FireFlutter가 활발히 개발되고 Firestore를 통해 사용되었습니다. 그러나 2024년 초에는 Realtime Database가 충분히 잘 구현될 수 있다는 것이 판명되어, 더 간결하고 빠르게 동작하는 패키지를 개발하기로 결정되었습니다. 결과적으로, 주로 Realtime Database를 사용하는 패키지가 개발되었습니다.

## 데이터베이스 가이드라인

- Firestore 대신 Realtime Database 를 사용하므로서
    - 데이터의 전체가 아닌 부분을 listen 할 수 있으며, 최소 단위의 데이터를 (DB 로 부터) 가져 올 수 있고,
    - 이로 인해 데이터를 보다 빠르게 가져와 화면에 보여 줄 수 있고,
    - 비용 절감의 효과를 가져 올 수 있다.

- 데이터베이 경로에는 가능한 언더바(_) 대신 하이픈(-)을 사용한다.
    - 예를 들면, `user_private` 대신 `user-private` 을 사용한다.

## 데이터베이스 구조

- 가능한 flat style 을 지향한다.
- 가능한 하위 데이터 구조를 포함하지 않는다. 예를 들면, 글 노드 하위에 코멘트를 보관하지 않는다.
  예를 들면,
    - `/posts/<postId>/comments/...` 와 같이 글 아래에 코멘트를 저장하지 하지 않고,
    - `/posts/<postId>` 에 글 저장, `/comments/<postId>/...` 에 코멘트을 하여 데이터 그룹을 분리한다.

## 데이터베이스 위젯

- 데이터베이스를 사용하기 쉽게 위젯을 제공한다.

### Value 위젯

Value 위젯은 Realtime Database 에 있는 정보를 실시간으로 화면에 보여준다. DB 에 있는 값을 화면에 보여줄 때에는 꼭 이 위젯을 사용하도록 한다.

`path` 에 DB 경로를 지정하면 `builder` 에 dynamic 타입으로 전달되어 온다. 만약 `path` 에 지정된 경로에 값이 없으면 null 값이 builder 로 전달된다.

DB 에 존재하는 값과 동일한 값을 `initialData` 에 주면 화면 깜빡거림을 현저하게 줄일 수 있다.

예제 1 - test/banana 노드 값을 화면에 보여준다.

```dart
Value(
  initialData: 'BANANA',
  path: 'test/banana',
  builder: (v) => Text(v.toString()),
),
```

예제 2 - 로그인 사용자의 전화번호를 화면에 보여준다.

```dart
Value(path: Path.phoneNumber, builder: (v) => Text(v ?? ''))
```

`onLoading` 에 loader 아이콘을 보여 줄 수도 있고, 기본 위젯을 보여주어 화면에 반짝임을 줄 일 수 있다.

```dart
Database(
  path: post.ref.child(Field.noOfLikes).path,
  builder: (no) => Text('좋아요${likeText(no)}'),
  onLoading: const Text('좋아요'),
),
```

`Value.once` 를 통해서, 화면에 한번만 값을 보여 줄 수 있다. 즉, 값이 계속 해서 수정되는 경우, 실시간으로 화면에 표시하는 것이 아니라, 처음 한번만 값을 가져와 화면에 보여주고 업데이트가 되어도 화면에 보여주지 않는다.

```dart
Value.once(
  initialData: 'BANANA',
  path: 'test/banana',
  builder: (v) => Text(v.toString()),
),
```

## User Database

See [user document](user.md).
