# 친구

Fireflutter는 사용자 간에 친구 시스템을 제공합니다.

## 서비스

Fireflutter는 친구 시스템과 관련된 기능을 돕는 친구 서비스를 제공합니다.

아래 코드와 같이 친구 서비스를 사용하세요.

```dart
FriendService.instance.showFriendScreen(context);
```

Firebase 규칙을 올바르게 추가해야 합니다. (이것은 Fireflutter 규칙에 이미 포함되어 있습니다).

```rules
// 친구
"friends": {
    ".read": true,
    "$myUid": {
        "$friendUid": {
            ".write": "$myUid == auth.uid || $friendUid == auth.uid"
        }
    }
},
"friends-sent": {
    ".read": true,
    "$senderUid": {
        "$receiverUid": {
            ".write": "$senderUid == auth.uid || $receiverUid == auth.uid"
        }
    }
},
"friends-received": {
    ".read": true,
    "$receiverUid": {
        "$senderUid": {
            ".write": "$senderUid == auth.uid || $receiverUid == auth.uid"
        }
    }
},
```

### 친구 목록 표시
현재 사용자의 친구 목록을 표시하려면 아래 코드를 사용하세요.

```dart
FriendService.instance.showFriendScreen(context);
```

### 받은 요청 화면 표시
현재 사용자가 다른 사용자로부터 받은 친구 요청을 표시하려면 아래 코드를 사용하세요.

```dart
FriendService.instance.showReceivedRequestScreen(context);
```

### 보낸 요청 화면 표시
현재 사용자가 다른 사용자에게 보낸 친구 요청을 표시하려면 아래 코드를 사용하세요.

```dart
FriendService.instance.showSentRequestScreen(context);
```

## 모델 (친구)

Fireflutter에서 시스템은 Friend를 데이터 모델로 사용합니다.

### 친구 요청

Friend 클래스는 친구 요청을 보내는 데 사용할 수 있습니다. 친구 요청을 보내려면 아래 코드를 사용하세요.

```dart
Friend.request(context: context, uid: "other-uid");
```

이 코드는 other-uid 사용자에게 요청을 보냅니다. createdAt 및 order 필드를 추가합니다. 내림차순으로 요청을 올바르게 정렬하기 위해 음수 값을 사용합니다.

### 친구 요청 수락

사용자가 친구 요청을 수락하도록 하려면 다음 코드를 사용하세요.

```dart
Friend.accept(context: context, uid: "other-uid");
```

이렇게 하면 acceptedAt 필드가 추가되고 order 필드가 업데이트됩니다. 또한 두 사용자의 friends RTDB 노드에 사용자가 추가됩니다. 즉, friends/my-uid/other-uid/... 및 friends/other-uid/my-uid/...에 추가됩니다.

rejectedAt에 값이 있는 경우 제거됩니다.

### 친구 요청 거부

사용자가 친구 요청을 거부하도록 하려면 다음 코드를 사용하세요.

```dart
Friend.reject(context: context, uid: "other-uid");
```

이렇게 하면 rejectedAt 필드가 추가되고 order 필드가 업데이트됩니다.

### 친구 요청 취소
사용자가 친구 요청을 취소하도록 하려면 다음 코드를 사용하세요.

```dart
Friend.cancel(context: context, uid: "other-uid");
```

이것은 단순히 다른 사용자의 friend-received RTDB 노드와 현재 사용자의 friend-sent RTDB 노드에서 요청을 제거합니다.

### 친구 요청 버튼

Fireflutter에는 친구 요청을 위한 기본 버튼이 있습니다.

```dart
FriendRequestButton(uid: userUid);
```

친구 요청 버튼은 친구 요청 보내기, 친구 요청 수락, 친구 요청 거부, 친구 요청 취소에 사용할 수 있습니다.

버튼은 다른 사용자가 현재 사용자의 요청을 거부했는지 알려주지 않습니다.