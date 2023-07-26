# EasyChat

* This package helps the flutter developers to rapidly build chat app.

- [EasyChat](#easychat)
- [TODO](#todo)
- [Overview](#overview)
  - [Principle of Design](#principle-of-design)
  - [Features](#features)
- [Environment](#environment)
- [Features](#features-1)
- [Setup](#setup)
  - [Firebase Setup](#firebase-setup)
    - [Firebase Users collection](#firebase-users-collection)
    - [Firestore Security Rules](#firestore-security-rules)
- [Widgets and Logics](#widgets-and-logics)
  - [Create a chat room](#create-a-chat-room)
  - [Additional information](#additional-information)
  - [How to test \& UI work Chat room screen](#how-to-test--ui-work-chat-room-screen)
- [Firebase](#firebase)
  - [Security Rules](#security-rules)
- [Logic](#logic)
  - [Fields](#fields)
    - [Chat room fields](#chat-room-fields)
    - [Chat user field](#chat-user-field)
  - [1:1 Chat and Multi user chat](#11-chat-and-multi-user-chat)
- [UI Customization](#ui-customization)
  - [Chat room list](#chat-room-list)
- [Run the Security Rule Test](#run-the-security-rule-test)


# TODO

- See the Principle.
- Login is required to use this app. Meaning, this package does not provide login relational feature. the parent app must provide login and login is reuqired for using this package.
- Create chat room.
- Updating user's display name and photo url in chat room collection. Not indivisual chat message.



# Overview

## Principle of Design

- Easychat provides logic as much as possible. This means, the app must provide UI and hook the user event with the easychat logic.
  - In some case, easychat must provide ui like displaying the list of chat friend list or chat room and message list. But still easychaht provides a way to customise everything.

- Easychat also provide sample UI. So, developer can see the code, copy and customise it.

- Easychat throws exceptions when there are problems. It is the app's responsibility to catch and handle them.
- For sample UI widgets, it provides `sucess` and `error` handler.


## Features

- The one who creats the chat room is the mater manager of the chat.
- The master manager can set moderators.
- Moderators can
  - kick out chat members.
  - block chat members not to join again.
  - set password so other member may not join.

- `OpenChat`
  - A group chat which is searchable.
  - Anybody search chat room and join.

- `PrivateChat`
  - A group chat which is not searchable.



# Environment

* Firestore

# Features

* Chat room list
* 1:1 chat room & multi chat
* File upload api

# Setup

## Firebase Setup

* Easychat package uses the same connection on your application. You can simply initialize firebase connection inside your application.


* The firestore structure for easychat is fixed. If you want to change, you may need to change the security rules and the source code of the package.
* `/easychat` is the root collection for all chat. The document inside this collection has chat room information.
* `/eachchat/{documentId}/messages` is the collection for storing all the chat messages.




### Firebase Users collection

* You can initialize the easychat to use your user list collection and It must be readable.
  * Easychat needs displayName and photoUrl in the collection.
  * Set the user's information like below.
```dart
EasyChat.instance.initialize(usersCollection: 'users', displayNameField: 'displayName', photoUrlField: 'photoUrl')
```


  * Warning! Once a user changes his displayName and photoUrl, `EasyChat.instance.updateUser()` must be called to update user information in easychat.


### Firestore Security Rules


* Copy the following security rules and paste it into your Firebase project.

```json
 ... security rules here ...
```



# Widgets and Logics

## Create a chat room

- To create a chat room, add a button and display `ChatRoomCreate` widget. You may copy the code from `ChatRoomCreate` and apply your own design.

```dart
class _ChatRoomListreenState extends State<ChatRoomListSreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Chat Room List'),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (_) => ChatRoomCreate(
                  success: () => Navigator.of(context).pop(),
                  cancel: () => Navigator.of(context).pop(),
                  error: () => const ScaffoldMessenger(child: Text('Error creating chat room')),
                ),
              );
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
```

- You need to create only one screen to use the easychat.


```dart
Scafolld(
  appBar: AppBar(
    title:
  )
)
```





## Additional information

- Please create issues.


## How to test & UI work Chat room screen

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


# Firebase

## Security Rules

- Run firestore emulator like below and test the security rules.

```sh
% firebase emulators:start --only firestore
```

# Logic

## Fields


### Chat room fields
- `master: [string]` is the master. root of the chat room.
- `moderators: Array[uid]` is the moderators.
- `group: [boolean]` - if true, it's group chat. otherwise it's 1:1 chat
- `open: [boolean]` - if true, any one in the room can invite and anyone can jogin (except if it's 1:1 chat). If it's false, no one can join except the invitation of master and moderators.
- `createdAt: [timestamp|date]` is the time that the chat room created.

### Chat user field

- `uid: [string]` is the uid. It is needed for security rules.
- `createdAt: [timestamp|date]` is the time that the user joined.

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
- The `inviting` means, the invitor will add the `invitee`'s uid into `users` field.
  - It is same as `joining`. If the user who wants to join the room, he will simply add his uid into `users` field. That's called `joining`.

- Any one can join the chat room if `/easychat/{id}/{ open: true }`.
  - 1:1 chat room must not have `{open: false}`.

- If a chat room has `{open: false}`, no body can join the room except the invitation of master and moderators.

- group chat room must have `{group: true, open: [boolean]}`. This is for searching purpose in Firestore.
  - For 1:1 chat room, it must be `{group: false, open: false}`. This is for searching purpose in Firestore.



# UI Customization

## Chat room list

```dart
ChatRoomListView(
  controller: controller,
  itemBuilder: (context, room) {
    return ListTile(
        leading: const Icon(Icons.chat),
        title: ChatRoomListTileName(
          room: room,
          style: const TextStyle(color: Colors.blue),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          controller.showChatRoom(context: context, room: room);
        });
  },
)
```


# Run the Security Rule Test

- To run all the tests
  - `% npm run test`


- To run a single test file, run like below.
  - `npm run mocha -- tests/xxxxx.spec.js`by dev1
