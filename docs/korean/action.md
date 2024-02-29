# 액션 로그

- 특정 활동(예: 프로필 보기 또는 채팅 등)을 중복 없이 기록하기 위한 것이다. 참고로 중복해서 기록이 필요하다면 activity 기능을 사용하면 된다.
- 한번만 기록하므로 특정 활동을 하루에 몇 번만 할 수 있도록 제한하기 위해서 사용할 수 있다. 그래서 카운트 기능을 포함하고 있다.
  - 카운트 기능을 사용하고, 해당 액션을 제한하려면, 미리 동작을 카운트 해 놓아야 한다. 채팅방 입장이나 프로필 보기를 할 때, 카운트를 하면 느려서 안된다.

- Action 기능은 Activity 기능과 유사한 면이 있고, 데이터가 겹쳐서 중복이 되기도 한다.



## 데이터베이스

- 한번 한 동작( 예: 한번 본 사용자의 경우 ) 두 번 카운트하지 않도록 설계한다. 즉, 24시간에 사용자 프로필을 5번 볼 수 있다면, 24시간 이전에 본 사용자의 프로필은 날짜가 오래되어 카운트에 속하지 않는다. 참고로, createdAt 값을 최신 값으로 변경하면, 현재로 부터 24시간 이내에 속하게 되므로, 다시 카운트가 된다. 따라사 리셋이 필요한 경우, 이 점을 잘 활용하면 된다.

- `action/<uid>/user-view/<otherUserUid> { createdAt: ... }` 은 다른 사용자 프로필 보기 기록 하는 것이다 처음 한번만 기록하고, 중복 기록을 하지 않는다.
- `action/<uid>/chat-join/<chatRoomId> { createdAt: ... }` 은 채팅방에 접속한 기록이다. 채팅 메시지를 전송하지 않고, 입장만 하면 바로 기록된다. 처음 한번만 기록하고, 중복 기록을 하지 않는다.
- `action/<uid>/post-create/<post-id>/ { createdAt: ..., category: ... }` 새 게시글 기록.
- `action/<uid>/comment-create/<post-id>/ { createdAt: ..., postId: ... }` 새 코멘트 기록.



참고, 사용자 프로필 보기와 채팅방 입장은 중복으로 이벤트(action)가 발생 할 수 있다. 이 때, 최초 한번만 기록한다.
주의, 좋아요는 기록하지 않는다. 좋아요는 좋아요 해제가 있어서, 조금 더 생각을 해 볼 필요가 있다.





## 활용

- 다른 사용자 프로필 보기를 1분에 3회로 제한 한 경우, 3회 제한이 걸리면, 이전에 본 다른 사용자의 프로필도 모두 볼 수 없다.
단, 이전에 본 사용자의 프로필을 다시 보기 해도, 카운트가 증가하지는 않는다.



- 게시 글 생성의 경우, limit 에 걸리면, 글 작성 페이지로 들어가기 전에 미리 사용자에게 알려주는 것이 좋다.



- 채팅방의 경우, 입장을 할 때, action 기록을 한다. 즉, 1분에 2 개로 제한하면, 1분 내에 2번째 입장은 허용한다. 단, 채팅을 할 때, 제한을 계산해서 에러를 표시하는데, 입장은 이미 했으나, 입장한 후 제한에 걸리게된다. 즉, 채팅 메시지를 두번째에서 못보내게 된다.


- 참고로 `init()` 함수는 여러번 호출 할 수 있고, 필요한 것만 init 하면 되고, 이전에 init 한 것들은 유지된다.


  // void initActivityService() {
  //   ActivityService.instance.init(
  //     userView: true,
  //     userLike: true,
  //     postCreate: true,
  //     commentCreate: true,
  //   );
  // }

  // void initActionService() {
  //   ActionService.instance.init(
  //     userView: ActionOption(enable: true, limit: 2, minutes: 2),
  //     chatJoin: ActionOption(enable: true, limit: 2, minutes: 2),
  //     postCreate: ActionOption(enable: true, limit: 2, minutes: 2),
  //     commentCreate: ActionOption(enable: true, limit: 2, minutes: 2),
  //   );
  // }
