# FireFlutter

A free, open source, complete, rapid development package for creating Social apps, Chat apps, Community(Forum) apps, Shopping mall apps, and much more based on Firebase

- [FireFlutter](#fireflutter)
  - [Features](#features)
  - [Getting started](#getting-started)
    - [Setup](#setup)
- [Usage](#usage)
  - [UserService](#userservice)
  - [ChatService](#chatservice)
    - [How to open 1:1 chat room](#how-to-open-11-chat-room)
- [Widgets](#widgets)
  - [UserDoc](#userdoc)
  - [Avatar](#avatar)
  - [UserAvatar](#useravatar)
  - [UserProfileAvatar](#userprofileavatar)
  - [User Filter List View](#user-filter-list-view)
  - [Translation](#translation)
  - [Contribution](#contribution)
- [OLD README](#old-readme)
  - [TODO](#todo)
  - [Overview](#overview)
    - [Principle of Design](#principle-of-design)
    - [Features](#features-1)
  - [Environment](#environment)
  - [Basic Features](#basic-features)
  - [Example](#example)
  - [Installation](#installation)
  - [Setup](#setup-1)
    - [Firebase Setup](#firebase-setup)
      - [Firebase Users collection](#firebase-users-collection)
    - [Updating auth custom claims](#updating-auth-custom-claims)
    - [Disable user](#disable-user)
      - [Firestore Security Rules](#firestore-security-rules)
      - [Firebase Indexes](#firebase-indexes)
  - [Widgets](#widgets-1)
    - [Chat Room List](#chat-room-list)
    - [Create a chat room](#create-a-chat-room)
    - [How to display a chat room](#how-to-display-a-chat-room)
    - [Additional information](#additional-information)
    - [How to test \& UI work Chat room screen](#how-to-test--ui-work-chat-room-screen)
  - [Firebase](#firebase)
    - [Security Rules](#security-rules)
  - [Logic](#logic)
    - [Fields](#fields)
      - [Chat Room fields](#chat-room-fields)
      - [Chat Message fields](#chat-message-fields)
    - [Counting no of new messages](#counting-no-of-new-messages)
    - [Displaying chat rooms that has new message (unread messages)](#displaying-chat-rooms-that-has-new-message-unread-messages)
    - [1:1 Chat and Multi user chat](#11-chat-and-multi-user-chat)
  - [UI Customization](#ui-customization)
    - [Chat room list](#chat-room-list-1)
  - [Chat Room Menu](#chat-room-menu)
  - [Chat Room Settings](#chat-room-settings)
  - [Run the Security Rule Test](#run-the-security-rule-test)
  - [Run the Logic Test](#run-the-logic-test)
- [Developers](#developers)
  - [How to add the easychat package as subtree into your project as the repo master](#how-to-add-the-easychat-package-as-subtree-into-your-project-as-the-repo-master)
  - [Deploy](#deploy)
  - [Unit Testing](#unit-testing)
    - [Testing on Local Emulators](#testing-on-local-emulators)
    - [Testing on real Firebase](#testing-on-real-firebase)
  - [Tips](#tips)
  - [Security rules](#security-rules-1)

## Features

- User management
- Chat
- Forum
- Push notification

## Getting started

If you want to build an app using FireFlutter, the best way is to copy codes from the example project.

### Setup

# Usage

## UserService

`UserService.instance.nullableUser` is null

- when the user didn't log in
- or when the user is logged in and has document, but the `UserService` has not read the user document, yet. In this case it simply needs to wait sometime.

`UserService.instance.nullableUser.exists` is false if the user has logged in but no document. In this case, the `documentNotExistBuilder` of `UserDoc` will be called.

So, the lifecyle will be the following when the app users `UserDoc`.

- `UserService.instance.nullableUser` will be null on app boot
- `UserService.instance.nullableUser` will have an instance of `User`
  - If the user document does not exists, `exists` will be `false` causing `documentNotExistsBuilder` to be called.
  - If the user document exsist, then it will have right data and `builder` will be called.

## ChatService

### How to open 1:1 chat room

Call the `showChatRoom` method anywhere with user model.

```dart
ChatService.instance.showChatRoom(context: context, user: user);
```

# Widgets

## UserDoc

To display user's profile photo, use like below.
See the comment for the details.

```dart
UserDoc(
  builder: (user) => UserProfileAvatar(
    user: user,
    size: 38,
    shadowBlurRadius: 0.0,
    onTap: () => context.push(ProfileScreen.routeName),
    defaultIcon: const FaIcon(FontAwesomeIcons.lightCircleUser, size: 38),
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  ),
  documentNotExistBuilder: () {
    // Create user document if not exists.
    UserService.instance.create();
    return const SizedBox.shrink();
  },
),
```

## Avatar

## UserAvatar

To display user's profile photo, use `UserAvatar`.
Not that, `UserAvatar` does not update the user photo in realtime. So, you may need to give a key when you want it to dsiplay new photo url.

```dart
UserAvatar(
  user: user,
  size: 120,
),
```

## UserProfileAvatar

To let user update or delete the profile photo, use like below.

```dart
UserProfileAvatar(
  user: user,
  size: 120,
  upload: true,
  delete: true,
),
```

## User List View

Use this widget to list users. By default, it will list all users. This widget can also
be used to search users by filtering a field with a string value.

This widget is a list view that has a `ListTile` in each item. So, it supports the properties of `ListView` and `ListTile` at the same time.

```dart
UserListView(
  searchText: 'nameValue',
  field: 'name',
),
```

Example of complete code for displaying the `UserListView` in a dialog with search box

```dart
onPressed() async {
  final user = await showGeneralDialog<User>(
    context: context,
    pageBuilder: (context, _, __) {
      TextEditingController search = TextEditingController();
      return StatefulBuilder(builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Find friends'),
          ),
          body: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: search,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search',
                  ),
                  onSubmitted: (value) => setState(() => search.text = value),
                ),
                Expanded(
                  child: UserListView(
                    key: ValueKey(search.text),
                    searchText: search.text,
                    field: 'name',
                    avatarBuilder: (user) => const Text('Photo'),
                    titleBuilder: (user) => Text(user?.uid ?? ''),
                    subtitleBuilder: (user) => Text(user?.phoneNumber ?? ''),
                    trailingBuilder: (user) => const Icon(Icons.add),
                    onTap: (user) => context.pop(user),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
```

## Translation

I feel like the standard i18n feature is a bit heavy and searched for other i18n packages. And I decided to write a simple i18n code for fireflutter.

The i18n code is in `lib/i18n/t.dart`.

By default, it supports English and you can change it to any language.

Here is an example of updating the translation.

```dart
tr.user.loginFirst = '로그인을 해 주세요.';
```

## Contribution

Fork the fireflutter and create your own branch. Then update code and push, then pull request.

# OLD README

- Below are the old read files.

## TODO

- See the Principle.
- Login is required to use this app. Meaning, this package does not provide login relational feature. the parent app must provide login and login is reuqired for using this package.
- Create chat room.
- Updating user's display name and photo url in chat room collection. Not indivisual chat message.

## Overview

### Principle of Design

- This firebase extension helps to manage your firebase.

- When a document is created under the `easy-commands` collection,

  - The firebase background function will execute the comamnd specified in `{ command: ... }`.

- Easychat provides logic as much as possible. This means, the app must provide UI and hook the user event with the easychat logic.

  - In some case, easychat must provide ui like displaying the list of chat friend list or chat room and message list. But still easychaht provides a way to customise everything.

- Easychat also provide sample UI. So, developer can see the code, copy and customise it.

- Easychat throws exceptions when there are problems. It is the app's responsibility to catch and handle them.
- For sample UI widgets, it provides `sucess` and `error` handler.

### Chat Room Features

- The one who creats the chat room is the master manager of the chat.
- The master manager can set moderators.
- Moderators can

  - kick out chat members.
  - block or unblock chat members not to join again.
  - set password so other member may not join.

- `OpenChat`

  - A group chat which is searchable.
  - Anybody search chat room and join.
  - Members of the group chat can invite other users.

- `PrivateChat`
  - A group chat which is not searchable.
  - Only Master and Moderators can invite users.

## Environment

- Firestore

## Basic Features

- Chat room list
- 1:1 chat room & multi chat
- File upload api

## Example

## Installation

- The example is in [easychat_example](https://github.com/thruthesky/easychat_example) repository. Add it in `apps` folder and test it.

## Setup

- [Beta (0.1.4-beta.0)](https://console.firebase.google.com/project/_/extensions/install?ref=jaehosong/easy-extension@0.1.4-beta.0)
- [Beta (0.1.0-beta.0)](https://console.firebase.google.com/project/_/extensions/install?ref=jaehosong/easy-extension@0.1.0-beta.0)
- [Alpha (0.0.21-alpha.1)](https://console.firebase.google.com/u/0/project/_/extensions/install?ref=jaehosong%2Feasy-extension@0.0.22-alpha.0)

### Firebase Setup

- Easychat package uses the same connection on your application. You can simply initialize firebase connection inside your application.

- The firestore structure for easychat is fixed. If you want to change, you may need to change the security rules and the source code of the package.
- `/easychat` is the root collection for all chat. The document inside this collection has chat room information.
- `/eachchat/{documentId}/messages` is the collection for storing all the chat messages.

#### Firebase Users collection

- You can initialize the easychat to use your user list collection and It must be readable.
  - Easychat needs displayName and photoUrl in the collection.
  - Set the user's information like below.

```dart
EasyChat.instance.initialize(usersCollection: 'users', displayNameField: 'displayName', photoUrlField: 'photoUrl')
```

- listen `eventarc` and update it into a document. For instance, after image processing, listen the event and update it on a document.

### Updating auth custom claims

- Required properties

  - `{ command: 'update_custom_claims' }` - the command.
  - `{ uid: 'xxx' }` - the user's uid that the claims will be applied to.
  - `{ claims: { key: value, xxx: xxx, ... } }` - other keys and values for the claims.

- example of document creation for update_custom claims

![Image Link](https://github.com/thruthesky/easy-extension/blob/main/docs/command-update_custom_claims_input.jpg?raw=true "This is image title")

- Response
  - `{ config: ... }` - the configuration of the extension
  - `{ response: { status: 'success' } }` - success respones
  - `{ response: { timestamp: xxxx } }` - the time that the executino had finished.
  - `{ response: { claims: { ..., ... } } }` - the claims that the user currently has. Not the claims that were requested for updating.

![Image Link](https://github.com/thruthesky/easy-extension/blob/main/docs/command-update_custom_claims_output.jpg?raw=true "This is image title")

- `SYNC_CUSTOM_CLAIMS_TO_USER_DOCUMENT` option only works with `update_custom_claims` command.
  - When it is set to `yes`, the claims of the user will be set to user's document.
  - By knowing user's custom claims,
    - the app can know that if the user is admin or not.
      - If the user is admin, then the app can show admin menu to the user.
    - Security rules can work better.

### Disable user

- Disabling a user means that they can't sign in anymore, nor refresh their ID token. In practice this means that within an hour of disabling the user they can no longer have a request.auth.uid in your security rules.

  - If you wish to block the user immediately, I recommend to run another command. Running `update_custom_claims` comand with `{ disabled: true }` and you can add it on security rules.
  - Additionally, you can enable `set enable field on user document` to yes. This will add `disabled` field on user documents and you can search(list) users who are disabled.

- `SET_DISABLED_USER_FIELD` option only works with `disable_user` command.

  - When it is set to yes, the `disabled` field with `true` will be set to user document.
  - Use this to know if the user is disabled.

- Request

```ts
{
  command: 'delete_user',
  uid: '--user-uid--',
}
```

- Warning! Once a user changes his displayName and photoUrl, `EasyChat.instance.updateUser()` must be called to update user information in easychat.

#### Firestore Security Rules

- Copy the following security rules and paste it into your Firebase project.

```json
 ... security rules here ...
```

#### Firebase Indexes

| Collection ID | Fields Indexd               |
| ------------- | --------------------------- |
| easychat      | users lastMessage.createdAt |

## Widgets

- In this chapter, the usage of the widgets is explained.

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

### Create a chat room

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
```

- You need to create only one screen to use the easychat.

```dart
Scafolld(
  appBar: AppBar(
    title:
  )
)
```

### How to display a chat room

- In the chat room, there should be a header, a message list view as a body, and message input box.
- To display the chat room, you need to have a chat room model.
  - To have a chat room model, you need to create a chat room (probably a group chat).
  - Then, you will get it on the app by accessing the database or you may compose it using `ChatRoomModel.fromMap()`.
  - Then, pass the chat room model into the chat room (or you can compose a chat room manually with the chat room model.)

### Additional information

- Please create issues.

### How to test & UI work Chat room screen

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

## Firebase

### Security Rules

- Run firestore emulator like below and test the security rules.

```sh
% firebase emulators:start --only firestore
```

## Logic

### Fields

#### Chat Room fields

- `master: [string]` is the master. root of the chat room.
- `moderators: Array[uid]` is the moderators.
- `group: [boolean]` - if true, it's group chat. otherwise it's 1:1 chat
- `open: [boolean]` - if true, any one in the room can invite and anyone can jogin (except if it's 1:1 chat). If it's false, no one can join except the invitation of master and moderators.
- `createdAt: [timestamp|date]` is the time that the chat room created.
- `users: Array[uid]` is the number of users.
- `noOfNewMessages: Map<string, number>` - This contains the uid of the chat room users as key and the number of new messages as value.
- `lastMessage: Map` is the last message in the room.
  - `createdAt: [timestamp|date]` is the time that the last message was sent.
  - `senderUid: [string]` is the sender Uid
  - `text: [string]` is the text in the message
- `maximumNoOfUsers: [int]` is the maximum no of users in the group.

#### Chat Message fields

- `text` is the text message [Optional] - Optional, meaning, a message can be sent without the text.
- `createdAt` is the time that the message was sent.
- `senderUid` is the sender Uid
- `imageUrl [String]` is the image's URL added to the message. [Optional]
- `fileUrl [String]` is the file's URL added to the message. [Optional]
- `fileName` is the file name of the file from `fileUrl`. [Optional]

### Counting no of new messages

- We don't seprate the storage of the no of new message from the chat room document. We have thought about it and finalized that that is not worth. It does not have any money and the logic isn't any simple.
- noOfNewMessages will have the uid and no. like `{uid-a: 5, uid-b: 0, uid-c: 2}`
- When somebody chats, increase the no of new messages except the sender.
- Wehn somebody receives a message in a chat room, make his no of new message to 0.
- When somebody enters the chat room, make his no of new message to 0.

### Displaying chat rooms that has new message (unread messages)

- Get whole list of chat room.
- Filter chat rooms that has 0 of noOfNewmessage of my uid.

### 1:1 Chat and Multi user chat

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
<!-- TODO for confirmation about password -->
- The `inviting` means, the invitor will add the `invitee`'s uid into `users` field.

  - It is same as `joining`. If the user who wants to join the room, he will simply add his uid into `users` field. That's called `joining`.

- Any one can join the chat room if `/easychat/{id}/{ open: true }`.

  - 1:1 chat room must not have `{open: false}`.

- If a chat room has `{open: false}`, no body can join the room except the invitation of master and moderators.

- group chat room must have `{group: true, open: [boolean]}`. This is for searching purpose in Firestore.
  - For 1:1 chat room, it must be `{group: false, open: false}`. This is for searching purpose in Firestore.

## UI Customization

UI can be customized

### Chat room list

- To list chat rooms, use the code below.

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
InviteUserButton(
  room: chatRoomModel,
  onInvite: (invitedUserUid) {
    debugPrint("You have just invited a user with a uid of $invitedUserUid");
  },
),
```

To programatically, invite a user, follow these codes:

```dart
updatedRoom = await EasyChat.instance.inviteUser(room: chatRoomModel, userUid: user.uid);
```

- `Settings` This can open the chat room settings. To use the button that opens the settings menu:

```dart
ChatSettingsButton(
  room: chatRoomModel,
  onUpdateRoomSetting: (updatedRoom) {
    debugPrint("Something was updated in the room. Setting ${updatedRoom.toString()}");
  },
),
```

See [Chat Room Settings](#chat-room-settings) for more details

- `Members` This is a List View of the members of the group chat. The user can be marked as [Master], [Moderator] and/or [Blocked]. Tapping the user will open a Dialog that may show options for Setting as Moderator, or Blocking on the group.

## Chat Room Settings

- `Open Chat Room` This setting determines if the group chat is open or private. Open means anybody can join and invite. Private means only the master or moderators can invite. See the code below to use the Default List Tile.

```dart
ChatRoomOpenSettingListTile(
  room: chatRoomModel,
  onToggleOpen: (updatedRoom) {
    debugPrint('Updated Room Open Setting. Setting: ${updatedRoom.open}');
  },
),
```

To programatically update the setting, follow the code below. It will return the room with updated setting.

```dart
updatedRoom = await EasyChat.instance.updateRoomSetting(
  room: chatRoomModel,
  setting: 'open',
  value: updatedBoolValue,
);
```

- `Maximum Number of User` This number sets the limitation for the number of users in the chat room. If the current number of users is equal or more than this setting, it will not proceed on adding the user.

```dart
ChatRoomMaximumUsersSettingListTile(
  room: chatRoomModel,
  onUpdateMaximumNoOfUsers: (updatedRoom) {
    debugPrint('Updated Maximum number of Users Setting. Setting: ${updatedRoom.maximumNoOfUsers}');
  },
),
```

To programatically update the setting, follow the code below. It will return the room with updated setting.

```dart
updatedRoom = await EasyChat.instance.updateRoomSetting(
  room: chatRoomModel,
  setting: 'maximumNoOfUsers',
  value: updatedIntValue
);
```

- `Default Chat Room Name` The master can use this setting to set the default name of the Group Chat.

```dart
ChatRoomDefaultRoomNameSettingListTile(
  room: _roomState!,
  onUpdateChatRoomName: (updatedRoom) {
    widget.onUpdateRoomSetting?.call(updatedRoom);
  },
),
```

To programatically update the default chat room name, follow the code below. It will return the room with updated setting.

```dart
updatedRoom = await EasyChat.instance.updateRoomSetting(
  room: chatRoomModel,
  setting: 'name',
  value: updatedName
);
```

## Run the Security Rule Test

- To run all the tests

  - `% npm run test`

- To run a single test file, run like below.
  - `npm run mocha -- tests/xxxxx.spec.js`by dev1

## Run the Logic Test

- We don't do the `unit test`, `widget test`, or `integration test`. Instead, we do `logic test` that is developed by ourselves for our test purpose.
  - You can see the test in `TestScreen`.

### Tests in Logic Test

The following are the available logic tests that can be used.

- Creating Group Chat Room
- Chat Room's Number of New Messages
- Maximum Nunber of Users Setting
- Creating Single Chat Room
- Inviting User into Single Chat
- Inviting User into Group Chat
- Changing the Default Chat Room Name
- Renaming Chat Room Own Side
- Updating Chat Room Password
  - Master can update the password
  - Moderator can update the password
  - Non-admin members should not be able to update the password
  - Password can be cleared

<!-- TODO: Insert Details per test -->

# Developers

## How to add the easychat package as subtree into your project as the repo master

- Note only the master need to as it as subtree.

- Add `easychat` as `git subtree` like below. Note that this is for package developers only.
  - Note that, the `easychat` may have its own `subtree` which means, it may have nested subtrees.

```sh
% flutter create [projectName]
% cd [projectName]
% flutter run
% git remote add origin [https://github.com/your-account/project-name]
% git add . && git commit -m "..."
% git push -f -u origin main
% git remote add easychat https://github.com/thruthesky/easychat
% git subtree add --prefix lib/easychat easychat main
% flutterfire configure
% flutter pub add firebase_core
% flutter pub add firebase_auth
% flutter pub add firebase_storage
% flutter pub add firebase_ui_firestore
% flutter pub add cloud_firestore
% ... add more packages ....
```

- Add the `easychat` package like below.

```yaml
easychat:
  path: lib/easychat
```

- Initialize firebase like below.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

- Enable the [easychat security rules](https://github.com/thruthesky/easychat/blob/main/easychat-security-rules/firestore.rules)

- Use the `TestUi` like below.

```dart
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: TestUi(),
    );
  }
}
```

- For wrong command, error like below will happen

```ts
{
  command: 'wrong-command',
  response: {
    code: 'execution/command-not-found',
    message: 'command execution error',
    status: 'error',
    timestamp: Timestamp { _seconds: 1690097695, _nanoseconds: 194000000 }
  }
}
```

- Take note that errors may occur when the multiple execution of testAll are concurrently running.

## Deploy

- To deploy to functions, run the command below.
  - `npm run deploy`

## Unit Testing

### Testing on Local Emulators

- We do unit testing on local emulator and on real Firebase.

- To test the input of the configuration based on extension.yaml, run the following
  - `cd functions/integration_tests && firebase emulators:start`
  - You can open `https://localhost:4000` to see everything works fine especially with the configuration of `*.env` based on the `extension.yaml` settings.

### Testing on real Firebase

- Test files are under `functions/tests`. This test files work with real Firebase. So, you may need provide a Firebase for test use.

  - You can run the emulator on the same folder where `functions/firebase.json` resides, and run the tests on the same folder.

- To run the sample test,

  - `npm run test:index`

- To run all the tests

  - `npm run test`

- To run a test by specifying a test script,
  - `npm run mocha -- tests/**/*.ts`
  - `npm run mocha -- tests/update_custom_claims/get_set.spec.ts`
  - `npm run mocha -- tests/update_custom_claims/update.spec.ts`

## Tips

- If you want, you can add `timestamp` field for listing.

## Security rules

- The `/easy-commands` collection should be protected by the admin users.
- See the [sample security rules](https://github.com/easy-extension/firestore.rules) that you may copy and use for the seurity rules of easy-extension.
