# 액티비티 로그

- 사용자가 어떤 행동(활동)을 하는지 기록을 남기기 위한 것이다.
- 예를 들면, 로그인한 사용자의 글 쓰기, 코멘트 쓰기, 좋아요, 프로필 보기 등의 활동을 기록하는 기능이다.
  - 단, 채팅 메시지 전송 및 프로필 수정 페이지 등 여러가지는 제외 될 수 있다.
- 중복으로 기록을 남기는 것이 특징이다. 예를 들어, A 가 B 를 좋아요 하면 기록이 생기고, 좋아요 해제를 해도 기록이 생기며 곧 바로 다시 좋아요 해도 기록이 생긴다. 만약 중복 기록을 원하지 않는다면, [Action](./action.md) 기능을 사용하면 된다.



## 데이터베이스

- `activity/<uid>/user-view` 는 다른 사용자의 공개 프로필 보기.
- `activity/<uid>/user-like` 는 사용자 프로필 좋아요.
- `activity/<uid>/post-create` 는 글 생성.
- `activity/<uid>/comment-create` 은 코멘트 생성.
- `activity/<uid>/chat-join` 은 채팅방 입장 기록. 동일한 채팅방에 여러번 입장을 해도, 입장 할 때마다 기록이 된다.



각 데이터는 아래와 같은 구조를 가진다.

```json
{
  createdAt: ...server-timestamp...
  category: ...,
  postId: ...,
  commentId: ...,
  otherUserUid: ...,
  chatRoomId: ...,
}
```

위 구조에서,
- 글의 경우 postId 와 category 가 같이 저장되고,
- 코멘트의 경우, commentId 와 postId 가 같이 저장된다.
- 다른 사용자의 프로필을 보는 경우, otherUserUid 에 해당 사용자의 uid 가 저장된다.
- 채팅방에 입장하는 경우, chatRoomId 가 저장된다.



참고로 프로실 수정(profile update) 는 하지 않는데, 그 이유는

- 프로필 수정은 여러 장소에서 여러 형태로 나타날 수 있다.
  예를 들면, 필수 정보 입력을 할 때 또는 이름을 입력하는 UI 가 다를 때 등. 그리고 프로필 수정 페이지 등에서 할 수 있는데, 너무 찾은 프로필 수정이 발생하거나 어디서 하는 것인지, 또 코드를 어디에 적용해야하는지 햇갈리기 때문이다.


참고, Firestore 를 사용하면, A 가 B 를 좋아요 하면, B 가 나를 좋아요 한 사람들의 목록을 볼 수 있지만, Realtime Database 는 자료 구조를 다시 만들어야 해서, 그렇게 하지 않는다. 물론 별도의 자료구조를 만들면 가능할 것이다.

참고, A 가 B 를 좋아요 하면 `activity/<A>/<push-id>/{ createdAt: ..., otherUserUid: B}` 와 같이 생성된다. 그리고 좋아요 해제를 해도 또 생성되고, 다시 좋아요 해도 또 생성된다. 즉, 한 사용자에 대해서 여러번 좋아요/해제를 해도 할 때 마다 acitivty 가 생성된다.


## 사용하기

아래와 같이 설정을 하면, 해당 로그가 기록된다.

```dart
ActivityService.instance.init(
  userView: true,
  userLike: true,
  postCreate: true,
  commentCreate: true,
);
```


참고로, 아직 로그를 보여주는 위젯은 만들어 놓지 않은 상태이다.

