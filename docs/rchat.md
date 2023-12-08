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


You may create the chat room model programmatically. Just incase you know the chat room information but you want to get(load) it from database because it takes time. Then generate the room model programatically and pass it over that room list widget or chat input box widget.

```dart
room = RChatRoomModel.fromJson({
  'key': 'all',
  'ref': RChat.roomsRef.child('all'),
  'isGroupChat': true,
});
```