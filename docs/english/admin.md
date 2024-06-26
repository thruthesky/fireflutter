# Admin

## Summary

- The administrator function can be used to check who the administrator is, chat with the administrator, etc.

- Designate an administrator
 - The consultation manager can provide the `chat` option, such as `admins/{uid: ['chat']}`.

## reset

- When `AdminService.instance.init()` is called, the list of administrators is retrieved from the RTDB server and managed (real-time update).
 - In other words, if `AdminService.instance.init()` is not called, administrator information may not be downloaded to the app and administrator functions may not operate properly.
 - Using the administrator function in the app is optional, but it is better to use it to add management functions. For example, to chat with an administrator, you must use the administrator function.


## Check if you are the administrator

- You can check whether you are an administrator or not with `AdminService.instance.isAdmin`.

- When the DB changes or the user UID changes, if you want to update in real time with StreamBuilder, you can do it as follows.

```dart
StreamBuilder(
 stream: AdminService.instance.isAdminStream;
 builder: (context, snapshot) {
 if (snapshot.connectionState == ConnectionState.waiting) {
 return const SizeBox();
 }

 if (snapshot.data != true) return const SizeBox();

 return Text('You are an admin');
 }
);
```

## Chat with an administrator

- For reference, when you chat with the administrator, a push notification message is automatically sent to the administrator.

- `AdminService.instance.chatAdminUid` contains the UID of the administrator in charge of chatting. So, to chat with the administrator, do the following:

```dart
final room = ChatRoom.fromUid(AdminService.instance.chatAdminUid!);
ChatService.instance.showChatRoomScreen(roomId: roomId);
```

- To send a chat message directly without opening a chat window (1:1 chat room) with the administrator, follow the steps below.

```dart
ChatModel chat = ChatModel(
 room: ChatRoom.fromUid(AdminService.instance.chatAdminUid!);
);
await chat.room.join();
await chat.room.reload();

chat.sendMessage(
 text: text,
 force: true;
);
```


- Among administrators, there must be a chat counselor dedicated to customer consultation (in-app inquiries). Such a consultation manager adds and saves the `chat` option, such as `admins/{uid: ['chat']}`. However, note that there must be only one administrator with the chat option.
 - For reference, when you first create admins data in the Firebase console, click the `+` button in the Realtime Database, set the key to `admins`, the value to `{"FjCrteoXHgdYi6MjRp09d51F71H3": "chat"}`, and the Type to `admins`. Just set it to `auto`.



## Administrator screen



- When `AdminService.instance.showDashboard()` is called, the basic administrator screen provided by FireFlutter appears.

### Admin Report Screen

- You can display Admin Report Screen by calling the `AdminService.instance.showAdminReportScreen()` this will open a new screen that you can manage the request, reject, accepted list of reports 

- You can use `DefaultAdminReportScreen()` to display Admin Report screen separately. 


```dart
IsAdmin(
    builder: () => DefaultAdminReportScreen(),
    notAdminBuilder: ()=> Text('Not an Admin'),
);
```