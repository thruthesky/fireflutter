# Chat

## Design Concept

- You can open multiple chat rooms simultaneously.

## Chat Database

- `/chat-rooms` stores information about chat rooms.
- `/chat-messages` stores chat messages.
- `/chat-joins` indicates who is participating in which chat room. Both `/chat-rooms` and `/chat-joins` use the `ChatRoom`.
- `noOfUsers` is updated in `/chat-rooms` when a new user joins or leaves a group chat room,
    - and is updated in `/chat-joins` when a chat message is sent.
- When sending a chat message, if the text contains a URL, information for previewing the URL is extracted. The appropriate values are stored in the following fields below the message:
    - `previewUrl` - URL
    - `previewTitle` - Title
    - `previewDescription` - Description
    - `previewImageUrl` - Image

### Chat Rooms

- `blocks`: Administrators manage the block list of chat rooms here. Users whose UIDs added here cannot enter the chat room. Additionally, they are automatically ejected from the chat room. (**TODO: Functionality not implemented as of 2024-02-22.**)

### Structure of Chat Messages

- uid: The UID of the user who sent the message.
- createdAt: The time when the message was sent.
- order: The order of the message in the list.
- text: The text message content.
- url: The URL of the photo if a photo was sent.

## Coding Technique

### Fetching All Users' Chat Messages in a Chat Room

By doing the following, you can retrieve all messages in the chat room sorted by `uid`. Be careful not to fetch too much data to avoid excessive download size.

```dart
// Get the chat room first.
final ChatModel chatRoom = await ChatModel.get('chat-room-id');

final snapshot = await ChatModel.messageseRef
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

### Get ChatRoom from ChatModel

- The `ChatModel` instance is needed before displaying the chat room message.
    - to check if the user is in the room,
    - to check if site preview displaying or image displaying options,
    - to show password input box based on the chat room settings,
    - etc

To clarify, `ChatRoom` and `ChatModel` are two different models. The `ChatRoom` is the model that holds some details of the chat room. The `ChatModel` is the complete model that holds all the details of the chat room and the chat messages. In short, the `ChatRoom` is accessible  `ChatModel.chatRoom`.

### Order

- Chat message order is sorted by the last message's `order` field.
    - The later message must have a smaller value than the previous message. Meaning the latest message always have the smallest value.
    - When you send a chat message programatically without `order`, the message may be shown at the wrong place (at the top).

### Creating Chat Room

A simple way to create a chat room is as follows:

```dart
ChatModel chat = ChatModel(room: ChatRoom.fromRoomdId('all'))..join();
ChatMessageListView(chat: chat);
```

Creating a `ChatModel` alone does not create the chat room. Therefore, `join()` is called additionally.

When join() is called, {[uid]: true} is created in /chat-rooms/all/users.

And when the `ChatMessageListView` widget is displayed on the screen, it internally saves `{order: 0}` in RTDB `chat-joins/all` in `ChatMessageListView::initState() -> ChatModel::resetNewMessage()`.

However, if you want to create a chat room more easily, you can use the pre-made `ChatService.instance.showChatRoomCreate()` function. If you want to customize the design, you can copy and modify `DefaultChatRoomEditDialog`.

### Viewing Chat Room

A `ChatRoomBody()` widget can be used to show chat room (room's messages with room input box).

```dart
// For 1:1 chat room, using other user's uid
ChatRoomBody(uid: 'user-uid');

...

// Using room-id for 1:1 or group chat room
ChatRoomBody(roomId: 'room-id');

...

// Using snapshot -> ChatRoom
ChatRoom chatRoom = ChatRoom.fromSnapshot(dataSnapshot);
ChatRoomBody(room: chatRoom);
```

### Updating Chat Room

To update a chat room, call `ChatService.instance.showChatRoomSettings(roomId: ...)`, and use the `DefaultChatRoomEditDialog` widget, which is the same widget used for creating a chat room.

When updating a chat room, you can optionally specify authenticated members and gender. If the `gender` has a value of `M` or `F`, only members of that gender can access (enter) the room. For `verified`, regardless of gender, if the user is verified, they can access the room. Note that authenticated members and gender refer to user information.

### Sending Chat Messages

To send a chat message into a room (or to a user), `ChatMessageInputBox()` can be used as Input box. You can copy this widget and customize by yourself.

```dart
// the ChatRoom is required. Get it.
ChatRoom room = ChatRoom.fromSnaphot(snapshot);

// the `chat` should be the model of the room
ChatModel chat = ChatModel(room: room);

ChatMessageInputBox(
  chat: chat,
),
```

You can also send a chat message to a user or to a room programatically (without entering a chat room screen) like below.

```dart
// the ChatRoom is required. Get it.
ChatRoom room = ChatRoom.fromSnaphot(snapshot);

ChatModel chat = ChatModel(room: room);

// This may throw error if user is not logged in.
chat.sendMessage(text: 'Text Message to send', url: 'photo.url.com');

```

### Getting Chat Messages in a Room

To display chat messages in a room, `ChatMessageListView()` can be used.

```dart
// the ChatRoom is required. Get it.
ChatRoom room = ChatRoom.fromSnaphot(snapshot);

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
        final message = ChatMessage.fromSnapshot(snapshot.docs[index]);

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

To open the Settings for the Chat Room

```dart
ChatService.instance.showChatRoomSettings(
  context: context,
  roomId: chat.room.id,
);
```

### Chat Room List

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
        final room = ChatRoom.fromSnapshot(snapshot.docs[index]);
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
await showGeneralDialog<ChatRoom?>(
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
  final ChatRoom room;
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
final room = ChatRoom.fromSnapshot(snapshot);
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

## Changing logic before sending chat messages

If you want to add logic before sending chat messages (or photos), you can use `testBeforeSendMessage`.

For example, if you don't want to send a chat message if the member doesn't have a photo or name, you can do the following.

```dart
ChatService.instance.init(testBeforeSendMessage: (chat) {
  if (my!.photoUrl.isEmpty || my!.displayName.isEmpty) {
    error(
        context: context,
        title: 'Incomplete Profile',
        message: 'Please fill in all missing profile information.');
    throw 'The profile is incomplete.';
  }
});
```

## Chat Message Sent Hook

If you want to perform certain actions after sending a chat message, you can use a hook.

For example, if you want to translate the sent chat message into another language after sending it, you can first send the chat message, then translate it using a translation API, and finally update the content of the sent chat message.

```dart
void initChatService() {
  ChatService.instance.init(
    onMessageSent: (ChatMessage message) async {
      /// You can perform desired actions here.
      /// For example, you can detect the language of the recipient and then translate the chat message using the https://pub.dev/packages/translator package
      /// After that, you can update the chat message as follows:
      /// This means automatically translating the chat message into another language.
      try {
        await message.ref!.update({
          Field.text:
              "Translated message: ...., original message: ${message.text}"
        });
      } catch (e) {
        dog('onMessageSent: ${e.toString()}, path: ${message.ref!.path}');
        rethrow;
      }
    },
  );
}
