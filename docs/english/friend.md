# Friend

Fireflutter has friend system between users.

## Service

Fireflutter has friend service that helps some functionalities related to friend system.

Use Friend Service like the code below.

```dart
FriendService.instance.showFriendScreen(context);
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

