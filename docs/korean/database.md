# 데이터베이스

Fireship 에서는 Realtime Database 를 사용합니다. 초기에는 Firestore 를 통해 (Fireship 의 전신인) FireFlutter 를 활발히 개발 및 사용하다가 2024년 초에 Realtime Database 로 충분히 잘 만들 수 있으며, 더 간결하고 빠르게 동작하는 패키지를 개발하자라는 생각에 Fireship 으로 패키지 명을 변경하고 Realtime Database 를 주로 사용하는 패키지를 개발하게 되었습니다.

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

Value 위젯은 Realtime Database 에 있는 정보를 실시간으로 화면에 보여준다.


예제 1 - 채팅방의 이름을 화면에 보여 준다.
```dart
Value(
    path: '${Path.join(myUid!, chat.room.id)}/name',
    builder: (v, p) => Text(
        v ?? '',
        style: Theme.of(context).textTheme.titleLarge,
    ),
),
```

예제 2 - 로그인 사용자의 전화번호를 화면에 보여준다.
```dart
Value(path: Path.phoneNumber, builder: (v) => Text(v ?? ''))
```


`onLoading` 을 사용해서 화면에 반짝임을 줄 일 수 있다. 물론 onLoading 에 loader 를 보여주어도 된다.

```dart
Database(
  path: post.ref.child(Field.noOfLikes).path,
  builder: (no) => Text('좋아요${likeText(no)}'),
  onLoading: const Text('좋아요'),
),
```


`Value.once` 를 통해서, 화면에 한번만 값을 보여 줄 수 있다. 즉, 값이 계속 해서 수정되는 경우, 실시간으로 화면에 표시하는 것이 아니라, 처음 한번만 값을 가져와 화면에 보여주고 업데이트가 되어도 화면에 보여주지 않는다.




## User Database

See [user document](user.md).
