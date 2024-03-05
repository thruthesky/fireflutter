# Action Log

- Action log is for logging/recording user activities as they uses the app without duplication. For example, logging actions such as viewing other users' profiles, entering chat rooms, writing posts, writing comments, etc.
    - Additionally, if logging multiple times of the same activity is needed, you can use the activity logging feature.
- The action log records activities without duplication. You can limit a number of logs to be recorded for specific activities to only a certain number of times per day.

## Database Structure

- This design of the system avoids couting single action twice. For example, if A views B's profile, the next views of B's profile by A should not be counted; only the initial view is recorded.
    - `action-logs/<uid>/user-profile-view/<otherUserUid>` logs instances of viewing another user's profile. It is designed to record only the initial view and does not allow duplicate recordings.
    - `action-logs/<uid>/chat-join/<chatRoomId>` logs entries into a chat room. It records entries without sending any chat messages; joining the chat room triggers the log entry. Like user profile views, it only records the initial entry and prevents duplicate recordings.
    - `action-logs/<uid>/comment-create/<post-id>/` logs the creation of a new comment along with the associated post ID.
    - `action-logs/<uid>/post-create/<category>/<post-id>/` logs the creation of a new post along with its category.
        - For forums or bulletin boards, actions are stored by category, allowing restrictions (or limiting of number of times to do the action) to be applied to each category separately.
        - When posting in a forum, an action log is saved under the `all` category, enabling unified restrictions across all categories.

## Utilizing Restriction Features

It can be used when restricting specific actions by users (e.g., viewing profiles or entering chat rooms).

For example, within 24 hours, you can prevent a user from viewing profiles of more than 5 different users (those not previously viewed). In other words, profiles viewed before are not counted.

Note that writing posts and comments do not occur redundantly. However, viewing user profiles and entering chat rooms can occur redundantly, in which case, only the initial occurrence is recorded.

Also note that likes are not recorded. Since there's the possibility of unliking, further consideration is needed.

### Note

- If viewing other users' profiles is limited to 3 times per minute, once the limit of 3 views is reached, the user cannot view any other profiles, including those previously viewed. However, viewing the profiles of users seen before will not increase the count.
- For post creation, it's advisable to inform the user before they enter the post creation page if they are nearing their limit.
- In the case of chat rooms, recording an action is triggered upon entry. Therefore, if the limit is set to 2 entries per minute, the second entry within a minute is allowed.

## Coding Explanation

Limiting actions per user:

- `limit` specifies the maximum number of actions allowed. If set to 0, no limit is applied. For example, setting it to 3 allows the action to be performed only three times. Note that setting a high value for this parameter may impact performance, so it's recommended to keep it within 100. Typically, values below 10 are suggested.
- `seconds` defines the time period in seconds for which the limit applies. For instance, if you want to allow 3 actions within 10 seconds, `limit` would be 3, and `seconds` would be 10.
- `overLimit` is a callback function that executes additional actions when the limit is reached. If this function returns false, the action continues to be performed. Therefore, ensure this callback function doesn't return any value.
- `debug` logs information to the console.
- The `ActionLogService.instance.init()` method is used to configure the limitations. This function maintains previous settings even if called multiple times. Therefore, you can initially set limitations for viewing user profiles and later add restrictions for chat at specific points within the app.

The following example restricts viewing user profiles, entering chat rooms, and creating comments. Note that post creation is not included in this example.

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

The example below illustrates limiting the number of posts a user can create based on their membership level (writing level).

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

Below, you can limit writing posts on the entire bulletin board.

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
