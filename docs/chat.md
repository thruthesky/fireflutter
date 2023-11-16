
# Chat

## Overview

Fireflutter offers a chat feature for your app. You can simply display a Chat room using a builder and just pass the data into its children, especially on Widgets. 


## Customization

### Chat room message box

To change the look of the message box, you can use `chatRoomMessageBoxBuilder` like below.

```dart title="How to customize the chat input box"
ChatService.instance.init(
    customize: ChatCustomize(
    chatRoomMessageBoxBuilder: (room) => const Text('Yo'),
    ),
);
```


For better UI, copy `lib/src/widget/chat/room/chat.room.message_box.dart` and paste it in your widget. And begin to customize from there.

The following example is a copied widget from the `chat.room.message_box.dart`. You can see how it could be customized.

```dart
class GrcChatRoomMessageBox extends StatefulWidget {
  const GrcChatRoomMessageBox({
    super.key,
    required this.room,
  });

  final Room? room;

  @override
  State<StatefulWidget> createState() => _ChatRoomMessageBoxState();
}

class _ChatRoomMessageBoxState extends State<GrcChatRoomMessageBox> {
  final TextEditingController message = TextEditingController();
  double? progress;

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          if (progress != null)
            LinearProgressIndicator(
              value: progress,
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ChatRoomMessageBoxUploadButton(
                  room: widget.room,
                  onProgress: (p) => setState(() => progress = p),
                ),
                Expanded(
                  child: TextField(
                    controller: message,
                    decoration: const InputDecoration(
                      hintText: 'Message',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.all(0),
                    ),
                    maxLines: 5,
                    minLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (widget.room == null) {
                      toast(title: 'Wait...', message: 'The room is not ready yet.');
                      return;
                    }
                    if (message.text.isEmpty) return;
                    final text = message.text;
                    message.text = '';
                    await ChatService.instance.sendMessage(
                      room: widget.room!,
                      text: text,
                    );
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```



## ChatService

You can use `ChatService` to enable chat features of the app or even customize the widget builder.

Here is a few example:

```dart
final service = ChatService.instance;
/// initialize all features
service.init()

/// get other's uid in 1:1 Chat Room; Parameter is optional
service.getSingleChatRoomId(otherUserId); // returns [String]

/// Get or Create a 1:1 Chat Room
service.getOrCreateSingleChatRoom(uid); // returns Future<Room>

/// Sends a message in room 
service.sendMessage(room: room, text: message); // returns Future<void>
```
### Open chat room

Use the `showChatRoom` method anywhere with user model. 

  **1:1 Chat Rom** 

```dart
ChatService.instance.showChatroom(context:context, room:room);
```
**Group Chat Room**

```dart
ChatService.instance.showChatRoom(context: context, user: user);
```

***Note:*** `showChatRoom()` has params of `showChatRoom(context: required BuildContext, user: User?, room: Room?)` _nulling_ either the ***user or room*** will differ in results. If your using `ChatRoomListView()` better specify what type of chats you will display to prevent errors and bugs.

### Display Chat Room Menu

To open default chat room menu see the code below and paste them into your project.

```dart
IconButton(
  icon: const Icon(Icons.settings),
  onPressed: () async {
    return ChatService.instance
        .openChatRoomMenuDialog(context: context, room: room);
  },
)
```
### Chat Room Dialog.

You can use dialog builders so you can open pages immediately.
```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Invite User'),
  ),
  body: CustomChatWidget(),
),
```

***Note:*** If your app throws an error `No Material Widget found...`, wrap your widgets inside of the `Scaffold()` or `SafeArea()`

## Welcome Message

To send a welcome chat message to a user who just registered, use `UserService.instance.sendWelcomeMessage`. See details on the comments of the source.

```dart
await FirebaseAuth.instance
    .createUserWithEmailAndPassword(email: email.text, password: password.text)
    .then(
      (value) => UserService.instance.sendWelcomeMessage(message: 'Welcome!'),
    );
```

## No of new message

FireFlutter save the no of new messages of users in RTDB. `/chats/noOfNewMessages/{uid}/{roomId: true}`.

```dart
NoOfNewMessageBadge(room:room),

// sample
ChatRoomListView(
  controller: controller,
  singleChatOnly: false,
  itemBuilder: (context, room) => ListTile(
    trailing: NoOfNewMessageBadge(room: room),
  ),
),
```

## Total no of new message

To display the total no of new messages, use the following widget. If you don't want to listen the changes of no of new message, then you can disable it with `ChatService.instance.init( ... )`

```dart
// Usage
TotalNoOfNewMessage(),

// To Disable
  @override
  void initState() {
    super.initState();
    ChatService.instance.init(
      listenTotalNoOfNewMessage: false,
    );
  }
```


### Chat Room List

- The beginning point would be chat room list screen.

  - On the chat room list screen, you can display chat room create icon and the login user's chat room list.

- Follow the setup first.

- You can display chat room list like below

```dart
final ChatRoomListViewController controller = ChatRoomListViewController();
ChatRoomListView(
  controller: controller,
),
```

You can customsize the chat room item in the list like below. You can replace the `ChatRoomListTile` or you can modify the onTap behavior.

```dart
ChatRoomListView(
  singleChatOnly: true,
  controller: controller,
  itemBuilder: (context, room) => ChatRoomListTile(
    room: room,
    onTap: () => controller.showChatRoom(context: context, room: room),
  ),
)
```

### Create a chat room

- To create a chat room, add a button and display `ChatRoomCreateDialog` widget. You may copy the code from `ChatRoomCreateDialog` and apply your own design.

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Easy Chat Room List'),
    actions: [
      IconButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (_) => ChatRoomCreateDialog(
              success: (room) {
                Navigator.of(context).pop();
                if (context.mounted) {
                  controller.showChatRoom(context: context, room: room);
                }
              },
              cancel: () => Navigator.of(context).pop(),
              error: () => const ScaffoldMessenger(child: Text('Error creating chat room')),
            ),
          );
        },
        icon: const Icon(Icons.add),
      ),
    ],
  ),
),
```

### Display a Chat Room

- In the chat room, there should be a header, a message list view as a body, and message input box.
- To display the chat room, you need to have a chat room model.
  - To have a chat room model, you need to create a chat room (probably a group chat).
  - Then, you will get it on the app by accessing the database or you may compose it using `ChatRoomModel.fromMap()`.
  - Then, pass the chat room model into the chat room (or you can compose a chat room manually with the chat room model.)

### Test UI Chat room screen

Follow this to test your Chat Room Screen UI. Modify this depends on your needs.
```dart

    Timer.run(() {
      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));

// How to test a chat room screen:
      Navigator.of(context).push(
        MaterialPageRoute(
          /// Open the chat room screen with a chat room for the UI work and testing.
          builder: (_) => ExampleChatRoomScreen(
            /// Get the chat room from the firestore and pass it to the screen for the test.
            room: ChatRoomModel.fromMap(
              id: 'mFpHRSZLCemCfC2B9Y3B',
              map: {
                'name': 'Test Chat Room',
              },
            ),
          ),
        ),
      );
    });
```
#### Chat Room field

```dart
Room(
  roomId: String,
  name: String,
  rename: {}, // Set {String,String}
  group: bool,
  open: bool,
  master: String,
  users: [], // Array[uid]
  moderators: [], // Array[uid]
  blockedUsers: [], // Array[uid]
  maximumNoOfUsers: int,
  createdAt: DateTime,
  lastMessage: {}, // Map<String,dynamic>
);
```

- `roomId: [string]` id of the room.
- `name: [string]` current name of the room.
- `rename: <String,String>` history of previous room's name.
- `group: [boolean]` - if true, it's group chat. otherwise it's 1:1 chat
- `open: [boolean]` - if true, any one in the room can invite and anyone can login (except if it's 1:1 chat). If it's false, no one can join except the invitation of master and moderators.
- `master: [string]` is the master. root of the chat room.
- `users: Array[uid]` is the number of users.
- `moderators: Array[uid]` is the moderators.
- `blockedUsers: Array[uid]` collection of blocked users id.
- `maximumNoOfUsers: [int]` is the maximum no of users in the group.
- `createdAt: [timestamp|date]` is the time that the chat room created.
- `lastMessage: Map` is the last message in the room.
  - `createdAt: [timestamp|date]` is the time that the last message was sent.
  - `uid: [string]` is the sender Uid
  - `text: [string]` is the text in the message
<!-- - `noOfNewMessages: Map<string, number>` - This contains the uid of the chat room users as key and the number of new messages as value. -->

#### Chat Message fields

```dart
Message(
  id: String?,
  text: String, // required
  url: String, // required
  protocol: String, // required
  uid: String?,
  createdAt: DateTime, // required
  previewUrl: String?,
  previewTitle: String?,
  previewDescription: String?,
  previewImageUrl: String?,
  isUserChanged: bool?,
);
```
- `id` is the id of the current message. This may be null since the lastMessage of chat room has no id.
- `text` is the text message [Optional] - Optional, meaning, a message can be sent without the text.
- `protocol` what type of message the user sent
- `uid` is the sender Uid
- `createdAt` is the time that the message was sent.
- `previewUrl` url preview of the sent media
- `previewTitle` Title of the sent media
- `previewDescription` Description of the sent media
- `previewImageUrl` Image preview of the sent media
- `isUserChanged` use to check if the message is from the current user or from other user. You can use this to create a chat bubble from different users.

## UI Customization

UI can be customized or personalized using the `ChatService.instance.customize` or if you're using a widget from FireFlutter you can use the `Theme()` to style.

### Chat Customization

The fireflutter gives full customization of the chat feature. It has a lot of widgets and texts to customize and they are nested deep inside the widget layers. So, the fireflutter lets developers to register the builder functions to display(customize) the widgets that are being used in deep place of the chat feature.

Registering the build functions do not cause any performance issues since it only registers the build functions at app booting time. It does not build any widgets while registering.

Customize your own Chat Room header like this

```dart
ChatService.instance.customize.chatRoomAppBarBuilder ({room, user}) => customAppBar(context, room);
```
## Chat Room Menu

The chat room menu can be accessed by the Chat Room Menu Button. This will open the Chat Room Menu Screen.

```dart
ChatRoomMenuButton(
  room: chatRoomModel,
  onUpdateRoomSetting: (updatedRoom) {
    debugPrint("If a setting was updated. Setting: ${updatedRoom.toString()}");
  },
),
```

The Chat Room Menu consists the following:

- `Invite User` This button opens a List View of users that can be invited to the group chat. To use Invite User Button for List View, follow the code:

```dart
ChatRoomMenuUserInviteDialog(room: room),
```
See [Chat Room Settings](#chat-room-settings) for more details

- `Members` This is a List View of the members of the group chat. The user can be marked as [Master], [Moderator] and/or [Blocked]. Tapping the user will open a Dialog that may show options for Setting as Moderator, or Blocking on the group.

## Chat Room Settings

- `Open Chat Room` This setting determines if the group chat is open or private. Open means anybody can join and invite. Private means only the master or moderators can invite. See the code below to use the Default List Tile.

```dart
ChatRoomSettingsOpenListTile(
  room: chatRoomModel,
  onToggleOpen: (updatedRoom) {
    debugPrint('Updated Room Open Setting. Setting: ${updatedRoom.open}');
  },
),
```

To programatically update the setting, follow the code below. It will return the room with updated setting.

- `Maximum Number of User` This number sets the limitation for the number of users in the chat room. If the current number of users is equal or more than this setting, it will not proceed on adding the user.

```dart
ChatRoomSettingsMaximumUserListTile(
  room: chatRoomModel,
  onUpdateMaximumNoOfUsers: (updatedRoom) {
    debugPrint('Updated Maximum number of Users Setting. Setting: ${updatedRoom.maximumNoOfUsers}');
  },
),
```

To programatically update the setting, follow the code below. It will return the room with updated setting.

- `Default Chat Room Name` The master can use this setting to set the default name of the Group Chat.

```dart
ChatRoomSettingsDefaultRoomNameListTile(
  room: _roomState!,
  onUpdateChatRoomName: (updatedRoom) {
    widget.onUpdateRoomSetting?.call(updatedRoom);
  },
),
```


### Counting no of new messages

- We don't seprate the storage of the no of new message from the chat room document. We have thought about it and finalized that that is not worth. It does not have any money and the logic isn't any simple.
- noOfNewMessages will have the uid and no. like `{uid-a: 5, uid-b: 0, uid-c: 2}`
- When somebody chats, increase the no of new messages except the sender.
- Wehn somebody receives a message in a chat room, make his no of new message to 0.
- When somebody enters the chat room, make his no of new message to 0.

## Displaying chat rooms that has new message (unread messages)

- Get whole list of chat room.
- Filter chat rooms that has 0 of noOfNewmessage of my uid.

## 1:1 Chat and Multi user chat

- 1:1 chat room id must be consisted with `uid-uid` pattern in alphabetically sorted.

- When the login user taps on a chat room, it is considered that the user wants to enter the chat room. It may be a 1:1 chat or group chat.
  - In this case, the app will deliver `ChatRoomModel` as a prameter to chat room list screen and chat room list screen will open the chat room.
- When the login user taps on a user, it means, the login user want to chat with the user. It will be only 1:1 chat.
  - Int his case, the app will deliver `UserModel` as a parameter to chat room list screen and chat room list screen will open the chat room.
  - When the login user taps on a user, the app must search if the 1:1 chat room exsits.
    - If yes, enter the chat room,
    - If not, create 1:1 chat room and put the two as a member of the chat room, and enter.
- When one of user in 1:1 chat invites another user, new group chat room will be created and the three users will be the starting members of the chat room.

  - And the new chat room is a group chat room and more members would invited (without creating another chat room).

- Any user in the chat room can invite other user unless it is password-locked.
- Onlt the master can update the password.
- The `inviting` means, the invitor will add the `invitee`'s uid into `users` field.

  - It is same as `joining`. If the user who wants to join the room, he will simply add his uid into `users` field. That's called `joining`.

- If a chat room has `{open: false}`, no body can join the room except the invitation of master and moderators.

- group chat room must have `{group: true, open: [boolean]}`. This is for searching purpose in Firestore.
  - For 1:1 chat room, it must be `{group: false, open: false}`. This is for searching purpose in Firestore.


## How to hook chat room open and check if the user has permission


```dart
initChatService() {
    ChatService.instance.init(
      customize: ChatCustomize(
        showChatRoom: ({required BuildContext context, Room? room, User? user}) {
          if (my!.isComplete || (user != null && user.uid == adminUid)) {
            return showGeneralDialog(
              context: context,
              pageBuilder: (_, __, ___) {
                return ChatRoomScreen(
                  room: room,
                  user: user,
                );
              },
            );
          } else {
            warningSnackbar(context, title: 'User verification', message: 'Please verify your identity before using chat service.');
          }
        },
      ),
    );
  }
```