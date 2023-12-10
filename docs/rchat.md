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



## Database structure

- `Flag string` is the string of the user value under `/chat-rooms/`
- 



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


## Chat room screen


You must set the current chat room's model with `RChat.setCurrentRoom()`. This will set the current chat room model object and keep it over the whole chat flow. The reason why we need it is because Flutter can pass value over reference but unless the state is updated, the children widget cannot use the updated value. So, save the current chat room object into a global space for the value update. It is necessary for accessing updated chat room info. for instance, sending a message to all users in the room. and if a user enters into the room, all the child widget should know the update of chat room info.

Example of updating chat room info.

```dart
subscription = room.ref.onValue.listen((event) {
	if (event.snapshot.exists) {
	RChat.setCurrentRoom(RChatRoomModel.fromSnapshot(event.snapshot));
	}
});
```

## Subscribing a chat room for push notification


If the subscription flag is set on other node or firestore, it has to read another data from server. And it costs. So, it being saved as the flag string.




## Sending a message


When a user chats

- If it's 1:1 chat room,
  - the message will be saved under `/chat-messages/{chat-room-id}`
  - the chat room will be updated on both of the login user and the other user.
    - `/chat-rooms/{login-user-uid}/{other-user-uid}` for the login user's chat room list.
    - `/chat-rooms/{other-user-uid}/{login-user-uid}` for the login user's chat room list.
  - the chat room info will have `name` field
    - For sender, the name will be the receiver's name.
    - For receiver, the name will be the sender's name.




When sending a message, 






