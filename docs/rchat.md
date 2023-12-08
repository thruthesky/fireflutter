# Realtime Database Chat





For group chat,

- when a user enters the group chat,
	- update room info under /chat-rooms/my-uid/group-chat-id
	- update /chat-rooms/group-chat-id/users/{my-uid: true}

- when a user leaves,
	- delete room /chat-rooms/my-uid/group-chat-id
	- delete /chat-rooms/group-chat-id/users/{my-uid}

- when a chat message is sent,
	- save a message under /chat-messages/group-chat-id
	- update the last message to all the chat room member's /chat-room/uid/group-chat-id and do the following works (like incrementing new message, sending push notifications)
	- but don't save the last message under /chat-rooms/group-chat-id/uid

- When a group is being created,
  - Update room under /chat-rooms/my-uid/groupd-id
  - Update a document under /chat-rooms/group-id
    - save my uid in /chat-rooms/group-id/users/{my-uid: true}
	- save isGroupChat to true
	- save isOpenGroupChat to true or false.
	- save room name
	- save createdAt






## Creating the RChatRoomModel


You may create the chat room model object programmatically. In case you want use the chat room model object immediately without loading it from database (since it would take time), You can use it like below.

```dart
    room = RChatRoomModel.fromGroupId('all');
```

`RChatRoomModel.fromGroupId(...)` creates a group chat room model object and make sure the chat room is really a gropu chat (Not a 1:1 chat). And after sometime later, you may load it from database like below.

```dart
    RChatRoomModel.fromReference(room.ref).then((value) => room = value);
```

The chat room object created by `RChatRoomModel.fromGroupId` or `RChatRoomModel.fromUid` is incomplete. For isntance, it does not have `users` field. So, you would loading it when you need it.