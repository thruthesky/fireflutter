# Friend

Fireflutter has friend system between users.

## Service

Fireflutter has friend service that helps some functionalities related to friend system.

Use Friend Service like the code below.

```dart
FriendService.instance.showFriendScreen(context);
```

Be sure to add the correct Firebase rules. (This is already included in the Fireflutter rules).

```rules
// Friends
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

### Showing Friend List

To show the current user's friend list, use the code below:

```dart
FriendService.instance.showFriendScreen(context);
```

### Showing Received Request Screen

To show the current user's friend requests that were received from other users, use the code below:

```dart
FriendService.instance.showReceivedRequestScreen(context);
```

### Showing Sent Request Screen

To show the current user's friend requests that were sent to other users, use the code below:

```dart
FriendService.instance.showSentRequestScreen(context);
```

## Model (Friend)

In Fireflutter, the system uses the `Friend` as the data models.

### Request to be a Friend

The `Friend` class can be used to request to be a friend. To request to be a friend, use the code below:

```dart
Friend.request(context: context, uid: "other-uid");
```

This code will send a request to the `other-uid` user. It will add `createdAt` and `order` field. It uses negative value to sort the request properly in descending order.

### Accept Friend Request

To let the user accept the friend request, use this code:

```dart
Friend.accept(context: context, uid: "other-uid");
```

This will add `acceptedAt` field and update `order` field. This will also add the user in the `friends` RTDB node for both users, that is to `friends/my-uid/other-uid/...` and `friends/other-uid/my-uid/...`.

In case there is a value for `rejectedAt`, it will be removed.

### Reject Friend Request

To let the user reject the friend request, use this code:

```dart
Friend.reject(context: context, uid: "other-uid");
```

This will add `rejectedAt` field and update `order` field.

### Cancel Friend Request

To let the user cancel the friend request, use this code:

```dart
Friend.cancel(context: context, uid: "other-uid");
```

This will simply remove the request under the other user's `friend-received` RTDB node and the current user's `friend-sent` RTDB node.

## Friend Request Button

Fireflutter has a default button for friend request.

```dart
FriendRequestButton(uid: userUid);
```

The Friend Request button can be used to Send friend request, Accept friend request, Reject friend request and Cancel friend request.

Be aware that the button wont be telling the the other user rejected the request of the current user.
