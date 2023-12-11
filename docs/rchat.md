# Realtime Database Chat





## Database structure


- 1:1 chat and group chat has same field structure.
  - `/chat-messages` has all the messages for the chat rooms
  - `/chat-rooms` has all the chat room info.
  - `/chat-joins` has all the relations of who join which chat room. Consider it as my chat room list.

  In this structure, 1:1 chat room can have same structure of group chat and 1:1 chat. By the this, we can have more consistent logic and the 1:1 chat can turn into a group chat.

- `isGroupChat` is set to true if the chat room is for group chat.
  - But the type of chat room is determined by the chat room id.
    - If the chat room id has triple typen(`---`) in the middle, it is single chat. Otherwise it is a group chat.
    - This is because, the chat room type needed to be determined before the chat room exists.



- when a user leaves,
	- delete /chat-rooms/room-id/users/{my-uid}
	- delete /chat-joins/{my-uid}/{room-id}

- when a chat message is sent,
	- save a message under /chat-messages/room-id
	- don't update /chat-rooms/room-id
	- update the last message to all the chat room user's relation node /chat-joins/{my-uid}/{room-id} and do the following works (like incrementing new message, sending push notifications)







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




## Creating chat room logic


- When a chat room is created, (for both 1:1 and group chat)
  - Update room under /chat-rooms/{room-id}
    - save my uid in /chat-rooms/room-id/users/{my-uid: true}
	- save isGroupChat to true or false
	- save isOpenGroupChat to true or false.
	- save room name for group chat. for 1:1 chat, empty.
	- save createdAt



## Entering chat room

In this chapter, the logic of entering chat room is explained.


- To enter a chat room, the app must have the other user's uid or the chat room model object.

- In the chat room screen, it should set the `currentRoom` immediately without accessing database from server.

- Then, update the `currentRoom` from server and whenever there is update from server.
  - By updating the `currentRoom` in realtime, the whole chat flow can use the latest data like when sending messages, it will use the latest `users` information.


- when a user enters the chat,
	- set /chat-rooms/room-id/users/{my-uid: true} if not exists.
	- set /chat-joins/{my-uid}/{room-id} if not exists.








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

The app must send push messages to only the users who subscribed.


- The on/off option value of subscription is saved at `/chat-rooms/{room-id}/users/{uid: boolean}`. If it's true then the user is subscribed. If it's false, then it is unsubscribed.


- By default, when a user joins, it becomes true. When the user turns off the subscription, it becomes false. And when the user leaves, it will be deleted.





## Sending a message


When a user chats

- Add last message under `/chat-messages`.
- Add last message under `/chat-joins` for all the chat room members.
- Don't update last message under `/chat-rooms`.
- the chat room info will have `name` field
  - For 1:1 chat,
    - the receiver's name is set under sender's side.
    - the sender's name is set under receiver's side.
  - For group chat,
    - just save room name.



- `newMessage` must be set to null instead of 0 when it is being cleared. This is because when a user peaks on a chat room, the chat room list widget will set `newMessage` and if it's set to 0, the chat room will appear in the my chat room list.









## Code


To join to chat room,

```dart
RChat.setCurrentRoom(RChatRoomModel.fromRoomdId('all'));
RChat.joinRoom();
```

To verify

```dart
RChat.setCurrentRoom(RChatRoomModel.fromRoomdId(singleChatRoomId('two')));
await RChat.joinRoom();
final r = await RChatRoomModel.fromReference(RChat.currentRoom.ref);
assert(r.users != null && r.users!.length == 2);
```