# 채팅 (Chat)

## 디자인 컨셉 (Design Concept)

- 동시에 여러개의 채팅방을 열 수 있다 (You can open multiple chat rooms simultaneously).

## 채팅 데이터베이스 (Chat Database)

- `/chat-rooms` 에는 채팅방 정보를 저장한다 (stores information about chat rooms).
- `/chat-messages` 에는 채팅 메시지가 저장된다 (stores chat messages).
- `/chat-joins` 에는 누가 어떤 채팅방에 참여하고 있는지 관계를 나타낸다. `/chat-rooms` 와 `/chat-joins` 의 DB 구조가 매우 비슷하여 둘다 모두 `ChatRoomModel` 을 사용한다.

- `noOfUsers` 는 그룹 채팅방에 새로운 사용자가 join 또는 leave 할 때, `/chat-rooms` 에 업데이트되고,

  - 메시지를 전송 할 때 `/chat-joins` 에 업데이트된다.

- 채팅 메시지를 전송 할 때, text 에 URL 이 들어가 있으면, url preview 할 수 있는 정보를 추출하여, 해당 메시지의 아래의 필드들에 적절한 값을 저장한다.
  - `previewUrl` - 해당 URL
  - `previewTitle` - 제목
  - `previewDescription` - 내용
  - `previewImageUrl` - 사진

## 로직 (Logic)

### Get ChatRoomModel on ChatRoom

- The complete chat room model instance is needed before display the chat room message. For instance,
  - to check if the user is in the room,
  - to check if site preview displaying or image displaying options,
  - to show password input box based on the chat room settings,
  - etc

### order

- Chat message order is sorted by the last message's `order` field.
  - It must have a smaller value than the previous message.
  - When you send a chat message programatically without `order`, the message may be shown at the top.

### 채팅방 생성 (Creating Chat Room)

간단하게 채팅방을 생성하는 방법은 아래와 같다.

```dart
ChatModel chat = ChatModel(room: ChatRoomModel.fromRoomdId('all'))..join();
ChatMessageListView(chat: chat);
```

ChatModel 만드는 것 만으로 채팅방이 만들어지지 않는다. 그래서 join() 을 추가적으로 호출한다.

`join()` 을 호출하면, `/chat-rooms/all/users` 에 `{[uid]: true}` 가 생성된다.

그리고 `ChatMessageListView` 위젯을 화면에 표시하면, 내부적으로 `ChatMessageListView::initState() -> ChatModel::resetNewMessage()` 에서 RTDB `chat-joins/all` 에 `{order: 0}` 을 저장한다.

그러나, 미리 만들어져 있는 `ChatService.instance.showChatRoomCreate()` 함수를 사용하면 보다 쉽게 채팅방을 생성 할 수 있다. 커스텀 디자인을 하고 싶다면, `DefaultChatRoomEditDialog` 를 복사해서 수정하면 된다.

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

### 채팅방 수정 (Updating Chat Room)

채팅방 수정은 `ChatService.instance.showChatRoomSettings(roomId: ...)` 를 호출하면 되며, 채팅방 생성과 같은 위젯인 `DefaultChatRoomEditDialog` 를 사용한다.

채팅방을 수정 할 때에는 추가적으로 인증 회원, 성별을 지정 할 수 있다. `gender` 에 `M` 또는 `F` 의 값이 지정되면, 해당 성별의 회원만 접속(채탕방 입장)이 가능하다. `verified` 의 경우, 남/녀 상관없이, 인증된 사용자 이면 접속 할 수 있다. 참고로 인증 회원과 성별은 회원 정보를 참고한다.

### 채팅방 메시지 전송 (Sending Chat Room Messages)

To send Chat message into a room, `ChatMessageInputBox()` can be used as Input box.

```dart
// the ChatRoomModel is required. Get it.
ChatRoomModel room = ChatRoomModel.fromSnaphot(snapshot);

// the `chat` should be the model of the room
ChatModel chat = ChatModel(room: room);

ChatMessageInputBox(
  chat: chat,
),
```

However, for more customization, here is the actual code to send a chat message. Edit these as needed.

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

RTDB 의 특성상 채팅방을 목록 할 때,

- 나의 1:1 채팅방 목록 중 날짜순
- 나의 전체 채팅방 목록 중 날짜순
- 오픈챗 목록 중 날짜순
  등으로 표시하기가 매우 힘들다.

그래서, isSingleChat: 에 음수의 시간을 지정해서, 나의 1:1 채팅방 목록에서 최근 채팅 채팅 목록으로 표시 할 수 있다.
이것은 isGroupChat 과 isOpenGroupChat 도 마찬가지이다.

그래서, 채팅방 목록 전체를 다 가져와서 한번에 표시한다. 즉, 나의 1:1 채팅방 목록을 할 때에는 나의 1:1 채팅방 목록 전체를 다 가져와서 날싸순으로 표시를 하는 것이다. 이것을 나의 전체 그룹 채팅, 그리고 모든 오픈 채팅과 동일하게 표시를 한다.
다만, 이렇게 하려면 개개인(사용자)의 채팅 방수가 너무 많으면 안된다. 전반적으로 1인당 500개 이하는 무난 할 것 같다. 2천개 이하도 괜찮을 것 같기도 하다. 다만 한 사용자의 방 수가 2천 개 이상 이면 좀 무리가 되지 않을까 싶다. 그래서 방수를 제한하는 것도 하나의 방법이겠다. 또한 오픈 챗의 개수가 2천개 이상 넘어가도 문제가 될 것 같다.

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

You can set true or false for my uid in the 'users' field of the chat room. Try this code:

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

<!-- TODO review 2 -->

## 관리 (Management)

- 기본 관리자 화면을 사용하면 된다. `AdminService.instance.showDashboard()` 를 호출하면 된다.

### 오픈 챗 목록 (Open Chat List)

### 오픈 챗 메시지 데이터 삭제 (Delete Open Chat Message Data)
