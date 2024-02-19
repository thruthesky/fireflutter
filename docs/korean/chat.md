# 채팅

## Design Concept

- You can open multiple chat rooms simultaneously.

## Chat 데이터베이스 구조

- `/chat-rooms` 채팅 방 정보를 저장하는 경로
- `/chat-messages` 채팅 메시지를 저장하는 경로
- `/chat-joins` 채팅 방에 참여한 사용자들에게 채팅방 정보를 장하는 경로. 예를 들어, 사용자별 읽지 않은 (새로운) 메시지 수를 표시하는 데 사용. 참고로, `/chat-rooms` 과 `/chat-joins` 둘 모두 `ChatRoomModel` 을 사용해서 modeling 한다.


- `noOfUsers` is updated in `/chat-rooms` when a new user joins or leaves a group chat room,

    - and is updated in `/chat-joins` when a chat message is sent.

- When sending a chat message, if the text contains a URL, information for previewing the URL is extracted. The appropriate values are stored in the following fields below the message:
    - `previewUrl` - URL
    - `previewTitle` - Title
    - `previewDescription` - Description
    - `previewImageUrl` - Image

### chat-messages 구조

- `uid` 메시지 전송한 사용자의 uid
- `createdAt` 메시지 전송한 시간
- `order` 메시지 목록 순서
- `text` 텍스트를 전송한 경우.
- `url` 사진 URL. 사진을 전송한 경우.



## 코딩 기법

### 채팅 방에서 사용자의 전체 채팅 메시지 가져오기

아래와 같이 하면, 해당 채팅방의 모든 메시지를 `uid` 순서로 한번에 다 가져온다. 다운로드 용량이 많아 데이터를 너무 가져오지 않도록 주의 할 필요가 있다.

```dart
final snapshot = await Ref.chatRoomMessages('chat-room-id')
    .orderByChild('uid')
    .get();

if (snapshot.exists) {
  print((snapshot.value as Map).keys.length);
  for (var key in (snapshot.value as Map).keys) {
    print((snapshot.value as Map)[key]['uid'] +
        ' : ' +
        ((snapshot.value as Map)[key]['text'] ?? '--'));
  }
}
```


### 채팅방에서 로그인한 사용자의 메시지 한 개만 가져오기

예를 들어, 모든 회원이 의무적으로(자동으로 채팅방 입장) 사용하는 전체 채팅방이 있는 경우, 회원 가입을 한 다음, 해당 채팅 방에 (가입인사) 채팅을 남기도록 권유하는 경우, 로그인 한 사용자가 해당 채팅방에 채팅을 했는지 안했는지 확인하기 위해서, 딱 하나의 채팅 메시지만 가져와서, 채팅을 했는지 하지 않았는지 알 수 있다.

아래와 같이 코딩을 하면 된다.

```dart
final snapshot = await Ref.chatRoomMessages('chat-room-id')
    .orderByChild('uid')
    .startAt(myUid!)
    .endAt('$myUid\f8ff')
    .limitToFirst(1)
    .get();

if (snapshot.exists) {
  print((snapshot.value as Map).entries.first.value['text']);
}
```



### Get ChatRoomModel on ChatRoom

- The complete chat room model instance is needed before display the chat room message. For instance,
    - to check if the user is in the room,
    - to check if site preview displaying or image displaying options,
    - to show password input box based on the chat room settings,
    - etc

### Order

- Chat message order is sorted by the last message's `order` field.
    - It must have a smaller value than the previous message.
    - When you send a chat message programatically without `order`, the message may be shown at the top.

### Creating Chat Room

A simple way to create a chat room is as follows:

```dart
ChatModel chat = ChatModel(room: ChatRoomModel.fromRoomdId('all'))..join();
ChatMessageListView(chat: chat);
```

Creating a `ChatModel` alone does not create the chat room. Therefore, `join()` is called additionally.

When join() is called, {[uid]: true} is created in /chat-rooms/all/users.

And when the `ChatMessageListView` widget is displayed on the screen, it internally saves `{order: 0}` in RTDB `chat-joins/all` in `ChatMessageListView::initState() -> ChatModel::resetNewMessage()`.

However, if you want to create a chat room more easily, you can use the pre-made `ChatService.instance.showChatRoomCreate()` function. If you want to customize the design, you can copy and modify `DefaultChatRoomEditDialog`.

### Viewing Chat Room

A `ChatRoom()` widget can be used to show chat room (room's messages with room input box).

```dart
// For 1:1 chat room, using other user's uid
ChatRoom(uid: 'user-uid');

...

// Using room-id for 1:1 or group chat room
ChatRoom(roomId: 'room-id');

...

// Using snapshot -> ChatRoomModel
ChatRoomModel chatRoom = ChatRoomModel.fromSnapshot(dataSnapshot);
ChatRoom(room: chatRoom);
```

### Updating Chat Room

To update a chat room, call `ChatService.instance.showChatRoomSettings(roomId: ...)`, and use the `DefaultChatRoomEditDialog` widget, which is the same widget used for creating a chat room.

When updating a chat room, you can optionally specify authenticated members and gender. If the `gender` has a value of `M` or `F`, only members of that gender can access (enter) the room. For `verified`, regardless of gender, if the user is verified, they can access the room. Note that authenticated members and gender refer to user information.

### Sending Chat Messages

To send a chat message into a room (or to a user), `ChatMessageInputBox()` can be used as Input box. You can copy this widget and customize by yourself.

```dart
// the ChatRoomModel is required. Get it.
ChatRoomModel room = ChatRoomModel.fromSnaphot(snapshot);

// the `chat` should be the model of the room
ChatModel chat = ChatModel(room: room);

ChatMessageInputBox(
  chat: chat,
),
```

You can also send a chat message to a user or to a room programatically (without entering a chat room screen) like below.

```dart
// the ChatRoomModel is required. Get it.
ChatRoomModel room = ChatRoomModel.fromSnaphot(snapshot);

ChatModel chat = ChatModel(room: room);

// This may throw error if user is not logged in.
chat.sendMessage(text: 'Text Message to send', url: 'photo.url.com');

```

### Getting Chat Messages in a Room

To display chat messages in a room, `ChatMessageListView()` can be used.

```dart
// the ChatRoomModel is required. Get it.
ChatRoomModel room = ChatRoomModel.fromSnaphot(snapshot);

// the `chat` should be the model of the room
ChatModel chat = ChatModel(room: room);

ChatMessageListView(
  chat: chat,
),
```

For customization, these can be used. Edit them as needed:

```dart
DatabaseReference ref = ChatService.instance.messageRef(roomId: roomId).orderByChild('order');

FirebaseDatabaseQueryBuilder(
  pageSize: 100,
  query: ref,
  builder: (context, snapshot, _) {
    if (snapshot.isFetching) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Something went wrong! ${snapshot.error}');
    }
    if (snapshot.docs.isEmpty) {
      return Center(child: Text('There is no message, yet.'));
    }
    // finally return the list
    return ListView.builder(
      reverse: true,
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
          snapshot.fetchMore();
        }
        final message = ChatMessageModel.fromSnapshot(snapshot.docs[index]);

        /// 채팅방의 맨 마지막 메시지의 order 를 지정.
        chat.resetRoomMessageOrder(order: message.order);

        return YourCustomChatBubble(
          message: message,
        );
      },

    );
  },
);

```

### Opening the Settings for the Chat Room

To open the

```dart
ChatService.instance.showChatRoomSettings(
  context: context,
  roomId: chat.room.id,
);
```

### 채팅방 목록 (Chat Room List)

Due to the characteristics of RTDB, it is challenging to list chat rooms:

- My 1:1 chat room list by date
- My entire chat room list by date
- Open chat list by date

Therefore, by using `isSingleChat` with a negative time, you can display my 1:1 chat room list in chronological order. This is the same for `isGroupChat` and `isOpenGroupChat`.

To display the entire chat room list at once, get all chat rooms and display them. For example, when displaying my 1:1 chat room list, get the entire list and display it in chronological order. Do the same for my entire group chat room and all open chat room. However, this method may not be suitable if each individual's (user's) chat rooms are too numerous. Overall, it seems reasonable to have up to 500 per person. Up to 2,000 should also be acceptable. However, if a user has more than 2,000 rooms, it might be a bit challenging. Therefore, limiting the number of rooms may be one way. Additionally, having more than 2,000 open chats might be problematic.

Here is an example code to show chat room list. This will show list of all Chat Rooms by the currently logged in user. Take note that the `Field.order` is the same as 'order'.

```dart
FirebaseDatabaseQueryBuilder(
  query: ChatService.instance.joinsRef
      .child(myUid!)
      .orderByChild(Field.order),
  pageSize: 50,
  builder: (context, snapshot, _) {
    if (snapshot.isFetching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Text('Something went wrong! ${snapshot.error}');
    }
    if (snapshot.hasMore == false && snapshot.docs.isEmpty) {
      return Text('No chat rooms');
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
          snapshot.fetchMore();
        }
        final room = ChatRoomModel.fromSnapshot(snapshot.docs[index]);
        return ChatRoomListTile(room: room);
      },
    );
  },
);

```

#### Chat List Widget

Fireship provides a default Widget for displaying a list of Chat Rooms if we don't have to customize it.

Chat List is a List view of Chats. We can use this widget to show a list of chats.

```dart
DefaultChatRoomListView(),
```

#### Querying Specific Type of Chat Rooms

You may want to show specific types of Chat Rooms, like Single Chat Rooms only, Group Chats Only, or Open Group Chats only.

##### Chat Rooms Joined by the Currently Logged in User (joinsRef)

In the earlier example, the query in FirebaseDatabaseQueryBuilder uses `Field.order`:

```dart
FirebaseDatabaseQueryBuilder(
  query: ChatService.instance.joinsRef
      .child(myUid!)
      .orderByChild(Field.order)
      .startAt(false),
  pageSize: 50,
  builder: (context, snapshot, _) {
    ...
  },
);
```

For `ChatService.instance.joinsRef.child(myUid!)`, the `joinsRef` is the reference for the chat rooms. In RTDB the node is `chat-joins/user-uid/room-id`. Therefore, `myUid` is required.

The `Field.order` is the same with 'order'. This can be used to get all the group chat that the currently logged in user is joined. Here are the list of fields can be used in `joinsRef`:

1. `Field.order` - same as 'order'.
   - All chat room - single or group chat
2. `Field.singleChatOrder` - same as 'singleChatOrder'.
   - All single chat room
3. `Field.groupChatOrder` - same as 'groupChatOrder'.
   - All group chat room

##### Chat Rooms not Necessarily Joined by the Currently Logged in User (roomsRef)

For `ChatService.instance.roomsRef`, the `roomsRef` is the reference for the chat rooms. In RTDB the node is `chat-rooms/roon-id`.

```dart
FirebaseDatabaseQueryBuilder(
  query: ChatService.instance.roomsRef
      .orderByChild(Field.openGroupChatOrder)
      .startAt(false),
  pageSize: 50,
  builder: (context, snapshot, _) {
    ...
  }
);
```

Here are the list of fields can be used in `roomsRef`:

1. `Field.groupChatOrder` - same as 'groupChatOrder'.
   - All group chat room - open or closed
2. `Field.openGroupChatOrder` - same as 'openGroupChatOrder'.
   - All open group chat room

## Toggling Notifications

The on and off switch for push notification is set under each user's uid in `users` field of the chat room.
For instance, if the value is `true` like `/chat-rooms/<room-id>/users/ {uid-a: true}`, then the user of `uid-a` will get push notification. If it's `false`, then the user will not get any push notification.

You can set true or false for the login uid in the 'users' field of the chat room like below;

```dart
IconButton(
  onPressed: () async {
    await chat.room.toggleNotifications();
  },
  icon: Database(
    path: Path.chatRoomUsersAt(chat.room.id, myUid!),
    builder: (v) => v == true
        ? const Icon(Icons.notifications_rounded)
        : const Icon(Icons.notifications_outlined),
  ),
),
```

When `v` is true, notifications is toggled on. Else, toggled off.

## Group Chat Room

### Creating a Group Chat

Use `ChatService.instance.showChatRoomCreate()` for the default way on creating a chat room.

```dart

IconButton(
  onPressed: () async {
    final room = await ChatService.instance.showChatRoomCreate(context: context);
    // It is recommended to show the newly created room to the user.
    if (room != null && mounted) {
      ChatService.instance.showChatRoom(context: context, roomId: room.id);
    }
  },
  icon: const Icon(Icons.comment),
),

```

Automatically, creator of the room will join to the newly created room after submitting.

### Inviting users into a Chat Room

To show the default invite screen, add these code:

```dart
IconButton(
  onPressed: () async {
    ChatService.instance.showInviteScreen(context: context, room: chat.room);
  },
  icon: const Icon(Icons.person_add_rounded),
),
```

The `ChatService.instance.showInviteScreen()` will show a list of users in a list view who can be added. It uses `DefaultChatRoomInviteScreen` widget. Check this code for reference in customization:

```dart
// Showing the list screen
await showGeneralDialog<ChatRoomModel?>(
  context: context,
  pageBuilder: (_, __, ___) => CustomChatRoomInviteScreen(room: room),
);
...
// Update this into your custom Invite screen
class CustomChatRoomInviteScreen extends StatelessWidget {
  const CustomChatRoomInviteScreen({
    super.key,
    required this.room,
  });
  final ChatRoomModel room;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 초대'),
      ),
      body: FirebaseDatabaseListView(
        query: Ref.users.orderByChild('order'),
        itemBuilder: (context, snapshot) {
          final user = UserModel.fromSnapshot(snapshot);
          return ListTile(
            leading: UserAvatar(uid: user.uid),
            title: Text(user.displayName ?? ''),
            trailing: const Icon(Icons.add),
            onTap: () async {
              await room.invite(user.uid);
            },
          );
        },
      ),
    );
  }
}
```

### Group Chat Members

To show the default members screen, add these code:

```dart
await ChatService.instance.showMembersScreen(
  context: context,
  room: chat.room,
);
```

It uses the `DefaultChatRoomMembersScreen(room: room)` when it is not customized.

### Removing a Group Chat Member

Here is an example of a button that removes a user from the group chat. It uses `room.remove(member.uid)` code to remove the user.

```dart
final room = ChatRoomModel.fromSnapshot(snapshot);
// ...
final member = UserModel.fromSnapshot(snapshot);
// ...
TextButton(
  onPressed: () {
    room.remove(member.uid);
    Navigator.pop(context);
  },
  child: const Text('Remove User'),
),
```

## Management

- You can use the default admin screen. Just call `AdminService.instance.showDashboard()`.

### Delete Open Chat Message Data

<!-- TODO -->



## 채팅 메시지를 전송하기 전에 로직 변경하기

채팅 메시지(또는 사진)를 전송하기 전에 원하는 로직을 추가하고 싶다면, `testBeforeSendMessage` 를 사용하면 된다.

예를 들어, 회원의 사진 또는 이름이 없는 상태라면 채팅 메시지를 보내지 않게 사려면 아래와 같이 하면 된다.


```dart
ChatService.instance.init(testBeforeSendMessage: (chat) {
  if (my!.photoUrl.isEmpty || my!.displayName.isEmpty) {
    error(
        context: context,
        title: '회원 정보 미완성',
        message: '빠진 회원 정보를 모두 입력해 주세요.');
    throw '프로필이 미완성입니다.';
  }
});
```

