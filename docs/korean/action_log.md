# 액션 로그

- 사용자가 앱을 사용할 때 발생하는 특정 활동을 중복없이 기록하는 것이다. 예를 들면, 다른 사용자의 프로필 보기나 채팅방 입장, 글 쓰기, 코멘트 쓰기 등의 해동을 기록하는 것이다.
    - 참고로 중복해서 기록이 필요하다면 활동 기록 기능을 사용하면 된다.
- 액션 로그는 중복없이 한 번만 기록하므로 특정 활동을 하루에 몇 번만 하도록 제한 할 때 사용 할 수 있다.
- 참고로 액션 로그 기능은 활동 기록 기능과 유사한 면이 있고, 데이터가 겹쳐서(같은 데이터가 이중으로) 저장 되기도 한다.

## 데이터베이스 설계

- 한번 한 동작을 두 번 카운트하지 않도록 설계한다.
  예를 들면, A 가 B 프로필을 보았다면, 그 이후 A 가 B 의 프로필을 몇 번을 더 보아도, 맨 처음 한번만 기록을 한다.
- `action-logs/<uid>/user-profile-view/<otherUserUid> { createdAt: ... }` 은 다른 사용자 프로필 보기 기록 하는 것이다 처음 한번만 기록하고, 중복 기록을 하지 않는다.
- `action-logs/<uid>/chat-join/<chatRoomId> { createdAt: ... }` 은 채팅방에 접속한 기록이다. 채팅 메시지를 전송하지 않고, 입장만 하면 바로 기록된다. 처음 한번만 기록하고, 중복 기록을 하지 않는다.
- `action-logs/<uid>/comment-create/<post-id>/ { createdAt: ..., postId: ... }` 새 코멘트 기록. 코멘트와 함께 기록을 한다.
- `action-logs/<uid>/post-create/<category>/<post-id>/ { createdAt: ..., category: ... }` 새 게시글 기록. category 와 함께 기록을 한다.
    - 게시판의 경우, category 별로 action 을 저장해서, 각 카테고리 별로 제한을 할 수 있으며,
    - 게시판의 글 쓰기를 하는 경우, 전체 카테고리인 `all` 에 액션 기록을 저장하여 전체 카테고리를 통합해서 제한 할 수 있다.

## 제한 기능 활용

기본적으로 사용자의 특정 액션(예: 프로필 보기 또는 채팅방 입장 등)을 제한 할 때 사용 할 수 있다.

예를 들면, 24시간 이내에 한 사용자가 (기존에 보지 않은) 다른 사용자 프로필을 5명 이상 보지 못하게 막을 수 있다. 즉, 이전에 본 사용자의 프로필은 카운트 하지 않는 것이다.

참고, 글 쓰기와 코멘트 쓰기는 중복 발생하지 않지만, 사용자 프로필 보기와 채팅방 입장은 중복으로 프로필 보기 및 채팅방 입장이 될 수 있는데, 이 때, 최초 한번만 기록한다.

참고, 좋아요는 기록하지 않는다. 좋아요는 좋아요 해제가 있어서, 조금 더 생각을 해 볼 필요가 있다.

### 주의 사항

- 이전에 본 사용자의 프로필을 다시 보기 해도, 카운트가 증가하지는 않는다.
  - 예를 들어, 24시간 동안 3 명의 프로필을 볼 수 있도록 제한을 한 경우, 100 명의 프로필도 볼 수 있다. 단, 신규 사용자(이전에 보지 않았던 사용자)의 프로필은 3 번 밖에 못 본다.
- 다른 사용자 프로필 보기를 1분에 3회로 제한 한 경우, 3회 제한이 걸리면, 이전에 본 다른 사용자의 프로필은 계속 볼 수 있지만, (이전에 보지 않았던) 새로운 프로필은 볼 수 없다.
- 게시 글 생성의 경우, limit 에 걸리면, 글 작성 페이지로 들어가기 전에 미리 사용자에게 알려주는 것이 좋다.
- 채팅방의 경우, 입장을 할 때, action 기록을 한다. 즉, 1분에 2 개로 제한하면, 1분 내에 2번째 입장은 허용한다.


## 로직 설명 - Logics

- You can set how you want it to retrict the user action with `ActionOption`.
- Based on the `ActionOption`, when the user did an action over limit, `overLimit` callback function is called.
- If you return false in `overLimit` callback function, the action will continue. You can do this if you want the user continue with the action.
- If `overLimit` function returns null or true, then the user is blocked to do the action. In this case, you should show some warning sign to the user.


## 코드 설명

다음은 사용자 별로 액션을 제한하는 예제이다.

- `limit` 에는 제한할 회수를 기록한다. 0 의 값을 주면 제한을 하지 않는다. 만약, 3 의 값을 주면, 해당 액션을 세 번만 허용한다.  참고로 이 값이 커지면, DB 에서 그 만큼 많은 데이터를 가져와야 하므로, 성능에 영향을 줄 수 있다. 그래서 최대 100 정도로 설정하는 것이 좋다. 보통 10 이내의 값을 주는 것을 권장한다.
- `seconds` 에는 초 단위 기간을 적어서, 몇 초 동안 제한을 할 것인지를 설정한다. 만약, 10초 동안 3개의 액션을 허용하고 싶다면, limit 은 3, seconds 는 10 이 된다.
- `overLimit` 은 limit 에 걸렸을 경우 추가적인 동작을 수행 할 있는 콜백함수이다. 글 쓰기, 코멘트 쓰기, 채팅방 입장, 사용자 프로필 보기 등에서 적절한 위치에서 각 `ActionLogService` 의 `ActionOption` 으로 지정된, `isOverLimit()` 를 호출한다. 그리고 만약, 이 함수에서 false 를 리턴하면, 해당 액션을 계속 수행한다. 즉, limit 에 걸려도 계속 해서 작업을 수쟁하고자 한다면, 이 함수에서 false 를 리턴하도록 하면 된다. 자세한 것은 로직 설명을 참고한다.
- `debug` 는 로그를 콘솔에 기록한다.

- `ActionLogService.instance.init()` 을 통해서 제한 설정을 하는데, 이 init 함수는 여러번 호출되어도 이전에 설정을 유지한다. 즉, 처음에 init 을 할 때, 사용자 프로필 보기만 제한 했다가, 다시 앱 내의 특정 시점에서 채팅 제한 설정을 추가할 수 있다.

아래의 예제는 사용자 프로필 보기, 채팅, 코멘트 생성을 제한한다. 참고로 글 생성은 빠져있다.

```dart
ActionLogService.instance.init(
  userProfileView: ActionLogOption(
    limit: 5,
    seconds: 10 * 60, // 10분에 최대 5명의 프로필 보기 가능
    overLimit: (option) async {
      toast(
        context: globalContext,
        message: 'You have viewed too many users.',
      );
      // 여기서 만약 false 를 리턴하면, 해당 동작을 제한하지 않고 계속 진행한다.
      return null;
    },
    debug: true,
  ),
  chatJoin: ActionLogOption(
    limit: 5,
    seconds: 60 * 60 * 2, // 2 시간에 최대 5 명과 채팅 가능
    overLimit: (option) async {
      toast(
        context: globalContext,
        message: 'You have entered too many chat rooms.',
      );
      return null;
    },
    debug: true,
  ),
  commentCreate: ActionLogOption(
    limit: 10,
    seconds: 60 * 60, // 1 시간에 최대 10개 코멘트 작성 가능.
    overLimit: (option) async {
      toast(
        context: globalContext,
        message: 'You have commented too many times.',
      );
      return null;
    },
    debug: true,
  ),
);
```

아래의 예제는 사용자의 멤버쉽(글 쓰기 레벨)에 따라서 글 쓰기 회 수를 제한하는 예제이다.

```dart
/// 사용자가 인앱결제를 했으면, Product ID 를 저장.
updateInAppPurchasedEntitlements(CustomerInfo customerInfo) async {
  /// 인앱결제한 Product ID 저장
  final PurchasedEntitlements ids = [];
  for (final entitlementId in EntitlementIDs.values) {
    if (customerInfo.entitlements.all[entitlementId.name] != null &&
        customerInfo.entitlements.all[entitlementId.name]!.isActive) {
      ids.add(entitlementId.name);
    }
  }
  purchasedEntitlements.add(ids);

  /// 인앱결제 구독에 따라서 글 쓰기 회 수 지정
  int limit = 0;
  if (ids.contains(EntitlementIDs.platinum.name)) {
    limit = 10;
  } else if (ids.contains(EntitlementIDs.gold.name)) {
    limit = 5;
  } else if (ids.contains(EntitlementIDs.silver.name)) {
    limit = 1;
  }

  /// 구인구직 게시판과 buyandsell 게시판만 제한하고, 나머지 게시판은 제한하지 않는다.
  ActionLogService.instance.init(
    postCreate: {
      'jobs': ActionLogOption(
        limit: limit,
        seconds: 60 * 60 * 24, // 24시간에 최대 limit 개의 글을 쓸 수 있다.
        overLimit: (option) async {
          toast(
            context: globalContext,
            message: option.limit == 0
                ? '구인 구직 게시판에 글 쓰기 권한이 없습니다.\n멤버쉽 구독을 해 주세요.'
                : '구인 구직 게시판에 ${(option.seconds / 60).toStringAsFixed(0)}분 동안 ${option.limit}개의 글을 쓸 수 있습니다.',
          );
          return null;
        },
        debug: true,
      ),
      'buyandsell': ActionLogOption(
        limit: limit,
        seconds: 60 * 60 * 24, // 24시간에 최대 limit 개의 글을 쓸 수 있다.
        overLimit: (option) async {
          toast(
            context: globalContext,
            message: option.limit == 0
                ? '회원 장터에 글 쓰기 권한이 없습니다.\n멤버쉽 구독을 해 주세요.'
                : '회원 장터에 ${(option.seconds / 60).toStringAsFixed(0)}분 동안 ${option.limit}개의 글을 쓸 수 있습니다.',
          );
          return null;
        },
        debug: true,
      ),
    },
  );
}
```

아래와 같이 전체 게시판 글 쓰기를 제한 할 수 있다.

```dart
ActionLogService.instance.init(
  postCreate: {
    'all': ActionLogOption(
      limit: 3,
      seconds: 60 * 20,
      overLimit: (option) async {
        toast(
          context: globalContext,
          message: '게시판 글 쓰기가 20분에 3회로 제한되어져 있습니다.',
        );
        return null;
      },
      debug: true,
    ),
  },
);
```




- chat join 로그 기록은 `chat.room_body.dart` 의 initState 에서 한다. 기록은 여기서 하지만, over limit 검사는 `chat.service.dart::showChatRoom` 에서 한다.