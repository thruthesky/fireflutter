# FireFlutter

![FireFlutter](https://github.com/thruthesky/fireflutter/blob/main/doc/fireflutter_title_image.jpg?raw=true)

If you are looking for a package that help you develop a full featured content management app, then you have found a right one. FireFlutter is a free, open source, complete, rapid development package for creating apps like CMS(content management system), social service, chat, community(forum), shopping mall and much more based on Firebase.

Create an issue if you find a bug or need a help.

# Table of Contents

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [FireFlutter](#fireflutter)
- [Table of Contents](#table-of-contents)
- [Overview](#overview)
- [Changes](#changes)
  - [Oct 10 0.3.12](#oct-10-0312)
  - [Sept 28 0.3.11](#sept-28-0311)
  - [Sept 10 0.3.10](#sept-10-0310)
  - [Features](#features)
    - [Main Features](#main-features)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Installing your app with fireflutter](#installing-your-app-with-fireflutter)
    - [Create a Firebase](#create-a-firebase)
- [Firebase Extension](#firebase-extension)
  - [Resize image](#resize-image)
  - [Install cloud functions](#install-cloud-functions)
  - [Security rules](#security-rules)
    - [Firestore security rules](#firestore-security-rules)
    - [Security rule for admin](#security-rule-for-admin)
    - [Realtime database security rules](#realtime-database-security-rules)
  - [Setup the base code](#setup-the-base-code)
- [Pub.dev Packages](#pubdev-packages)
  - [url_launcher (Optional)](#url_launcher-optional)
  - [timeago](#timeago)
  - [Parsed_ReadMore](#parsed_readmore)
- [Build Sample](#build-sample)
  - [User Profile Page](#user-profile-page)
  - [Chat App](#chat-app)
  - [Forum App](#forum-app)
- [Widgets and UI functions](#widgets-and-ui-functions)
- [Usage](#usage)
  - [User](#user)
  - [Admin](#admin)
  - [Chat](#chat)
  - [Post](#post)
  - [Comment](#comment)
  - [Share](#share)
- [Push notifications](#push-notifications)
- [Error handling](#error-handling)
- [Admin](#admin-1)
- [Developers](#developers)
- [Things to improve](#things-to-improve)

<!-- /code_chunk_output -->

# Overview

Fireflutter made for reusing the common code blocks. Provides code for user, forum, chat and push notificiation management with `like`, `favorite`, `follow`, `post` and `comment` features.

There are some pre-defined fields for the user document. You can use `json_serializable` for providing each model extra fields.

The model has also basic CRUD functionalities.

# Changes

<!-- You can see [CHANGELOG.md](/CHANGELOG.md) for the updated log. -->

### Oct 10 0.3.12

- Refactoring on user, feed.
- Refine widgets and services.

### Sept 28 0.3.11

- Add. Admin dashboarsd.
- Update. Push notification.
- Refactoring. Save more data in realtime database.

### Sept 10 0.3.10

- Change. Refactoring file/folder names.

Go to [CHANGELOG.md](/CHANGELOG.md) for more.

## Features

There are many features and most of them are optional. You may turn on the extra functions by creating an instance.

### Main Features

- User
- Chat
- Forum
- Push notification
- Like
- Favorite(Bookmark)
- Following
- Admin

# Getting started

To get started, you can follow the [Installation](#installation) chapter.

The best way is to copy codes from the example project and paste it into your project and update the UI.

## Installation

Follow the instruction below to install FireFlutter into your app

## Installing your app with fireflutter

- Fork the fireflutter. Go to `https://github.com/thruthesky/fireflutter` and fork it.
- Then, clone it

```sh
git clone https://github.com/your-account/fireflutter
```

- Create a branch in fireflutter local repository

```sh
cd fireflutter
git checkout -b work
```

- For `Pull Request`, update any file, commit, push and request for pulling your code.

```sh
echo "Hi" >> README.md
git commit -a -m "updating README.md"
git push --set-upstream origin work
```

- Create `apps` folder and create your app inside `apps` folder.

```dart
cd apps
flutter create your_project
```

- Since your project add the fireflutter from your computer folder, you need to add the path of the dependency as `../..`. Add the firefluter dependency like below.

```yaml
dependencies:
  fireflutter:
    path: ../..
```

### Create a Firebase

If you have your own firebase project, then you can use that. If you don't have one, create one first. Visit [Firebase Website](https://firebase.google.com).

# Firebase Extension

### Resize image

`Deletion of original file` - Don't delete  
`Make resized images public` - yes

![resize_image_settings](https://github.com/thruthesky/fireflutter/blob/main/doc/img/resize_option_1.png?raw=true)

`Cache-Control header for resized images` - "max-age=86400"
`Convert image to preferred types` - select `webp` only.

![resize_image_settings](https://github.com/thruthesky/fireflutter/blob/main/doc/img/resize_option_2.png?raw=true)

And choose `backfill` if you have an existing images.

![resize_image_settings](https://github.com/thruthesky/fireflutter/blob/main/doc/img/resize_option_3.png?raw=true)

All other options are on your choice.

To display the thumbnail image, you may use `.thumbnail` String extension method. `CachedNetworkImage(imageUrl: url.thumbnail)`

## Install cloud functions

Since the firebase extension does not support on sending push notification with node.js SDK, we just made this function as cloud function.
To install,

```sh
git clone https://github.com/thruthesky/fireflutter
cd fireflutter/firebase/functions
npm i
firebase use --add <project>
npm run deploy
```

**Note:**
if you see error like `v2 function name(s) can only contain lower case letters, numbers, hyphens, and not exceed 62 characters in length`, then install the latest version of npm, nodejs, firebase.

**Note:**
if you see warnings like `functions: Since this is your first time using 2nd gen functions, we need a little bit longer to finish setting everything up. Retry the deployment in a few minutes.`, then take 5 minutes break and re-deploy.

## Security rules

### Firestore security rules

Security rules for firestore are under `/firebase/firestore/firestore.rules`.

Copy [the security rules of fireflutter](https://raw.githubusercontent.com/thruthesky/fireflutter/main/firebase/firestore/firestore.rules) and paste it in your firebase project. You may need to copy only the parts of the necessary security rules.

To deploy firestore rules, follow this

```sh
 firebase deploy --only firestore:rules
```

### Security rule for admin

You can add your uid (or other user's uid) to the `adminUIDs` variable in `isAdmin` function in the security rule. With this way, you don't have to pay extra money for validating the user is admin or not.

```dart
function isAdmin() {
  let adminUIDs = ['root', 'admin', 'CYKk5Q79AmYKQEzw8A95UyEahiz1'];
  return request.auth.uid in adminUIDs || request.auth.token.admin == true;
}
```

After setting the admin, you can now customize your security rules to restrict some write access from other user. You can add sub-admin/s from client app without editing the security rules everytime.

For instance, you may write security rules like below and add the uids of sub-admin users. then, add a security rule function to check if the user is sub-admin.

```ts
  /settings/sub-admins {
    allow read, write: if isAdmin();
  }
  function isSubAdmin() {
    ...
  }
```

### Realtime database security rules

Enable Realtime Database on firebase and copy the following and paste it into your firebase project.

```json
{
  "rules": {
    "users": {
      ".read": true,
      "$uid": {
        ".write": "$uid === auth.uid"
      }
    },
    "chats": {
      "noOfNewMessages": {
        "$uid": {
          ".read": true,
          ".write": true
        }
      }
    },
    // User profile likes
    "likes": {
      ".read": true,
      "$uid": {
        "$other_uid": {
          ".write": "$other_uid === auth.uid"
        }
      }
    },
    "posts": {
      ".read": true,
      "$post_id": {
        "seenBy": {
          "$uid": {
            ".write": "$uid == auth.uid"
          }
        },
        // post likes
        "likedBy": {
          "$uid": {
            ".write": "$uid == auth.uid"
          }
        }
      }
    },
    "comments": {
      ".read": true,
      "$comment_id": {
        // comment likes
        "likedBy": {
          "$uid": {
            ".write": "$uid == auth.uid"
          }
        }
      }
    },
    "blocks": {
      "$my_uid": {
        ".read": "$my_uid == auth.uid",
        ".write": "$my_uid == auth.uid"
      }
    },
    "tmp": {
      ".read": true,
      ".write": true
    },
    "activity_logs": {
      ".read": true,
      ".write": true,
      ".indexOn": ["reverseCreatedAt"]
    },
    "activity_user_logs": {
      ".read": true,
      ".write": true,
      "$uid": {
        ".indexOn": ["reverseCreatedAt"]
      }
    }
  }
}
```

## Setup the base code

FireFlutter needs the app to initialize with the Firebase before using it.

Do the settings to connect to firebase.

```
flutterfire configure
```

Add firebase dependencies

```
flutter pub add firebase_core
flutter pub add firebase_auth
```

Then, connect your app to firebase.

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

Then, initialize FireFlutter like below

```dart
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    /// Initialize FireFlutter
    FireFlutterService.instance.init(context: ...);
  }
}
```

FireFlutter has many features and each feature has a singleton service class. You need to initialize each of the singleton on your needs.

FireFlutter needs **Global Key** since it uses `snackbars`, `dialog`, `bottom sheet`. Use the **`FireFlutterService.instance.init(context : ...)`**

**Note:** You don't have to initialize when you are only doing unit test.

**Note:** If you meet an error like `No MaterialLocalizations found. Xxxx widgets require MaterialLocalizations to be provided by a Localizations widget ancestor.`, then you may think a widget is not under MaterialApp or no localization provided. In this case, the context from global key will be used. For more details, See <https://docs.flutter.dev/release/breaking-changes/text-field-material-localizations>.

For instance, if you are using [go_route package](https://pub.dev/packages/go_router), you can pass the global build context like below.

```dart
//  initialize admin
UserService.instance.init(adminUid: 'xxx');

WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  FireFlutterService.instance.init(context: router.routerDelegate.navigatorKey.currentContext!);
})
```

If you are using the flutter's default `Navigator` for routing, define the global key like below first,

```dart
import 'package:flutter/material.dart';

GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();
BuildContext get globalContext => globalNavigatorKey.currentContext as BuildContext;
```

Then connect it to MaterialApp like below

```dart
MaterialApp(
  navigatorKey: globalNavigatorKey,
)
```

Then, store the global context into fireflutter like below

```dart
class _MainWidgetState extends State<MainWidget>{

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FireFlutterService.instance.init(
        context: globalContext,
      );
    });
  }
}
```

By default, feed feature is disabled. To use feed features, add the following in app widget.

```dart
FeedService.instance.init(enable: true);
```

# Pub.dev Packages

## url_launcher (Optional)

`url_lancher` package is added by fireflutter and it is being used to open url. If you wish to let users share links by sms, you need to setup in `AndroidManifest.xml` and `Info.plist`. See the [url_launch Configuration](https://pub.dev/packages/url_launcher#configuration).

FireFlutter exposes a method `launchSMS` to open the SMS app. Here is an example of how to send sms. You can build your own code, of course.

```dart
final re = await launchSMS(phnumber: '', msg: link);
if (re) {
  toast(title: 'SMS', message: 'Link sent by SMS');
} else {
  toast(title: 'SMS', message: 'Cannot open SMS');
}
```

In this chapter, some of the notable packages that are used by FireFlutter are explained.

## timeago

Converts date into a humanized text.

```dart
    final fifteenAgo = DateTime.now().subtract(Duration(minutes: 15));

    print(timeago.format(fifteenAgo)); // 15 minutes ago
    print(timeago.format(fifteenAgo, locale: 'en_short')); // 15m
    print(timeago.format(fifteenAgo, locale: 'es')); // hace 15 minutos
```

Visit [timeago](https://pub.dev/packages/timeago) to read more.

## Parsed_ReadMore

Allows the text to collapsed or expanded and automatically parse the url text to hyperlinks.

Visit [parsed_readmore](https://pub.dev/packages/parsed_readmore) to read more.

<!-- TODO: -->

# Build Sample

### User Profile Page

Here is an example of how to build simple user profile page.
![user_profile](https://github.com/thruthesky/fireflutter/blob/main/doc/img/user_profile.png?raw=true)

### Chat App

Here is an example of how to build simple user profile page.
![chat_app](/doc/img/chat_app.png)

### Forum App

<!-- FIXME: Not sure if I implemented this correctly -->

Here is a simple forum app.
![forum_result](/doc/img/forum.png)

See [User Profile](https://github.com/thruthesky/fireflutter/blob/main/doc/SAMPLES.md#how-to-build-a-user-profile-page?raw=true) for source code and detailed explanation.

# Widgets and UI functions

- The widgets in fireflutter can be a small piece of UI representation or it can be a full screen dialog.

- The file names and the class names of the widgets must match.
- The user widgets are inside `widgets/user` and the file name is in the form of `user.xxxx.dart` or `user.xxxx.dialog.dart`. And it goes the same to chat and forum.

- There are many service methods that opens a screen. One thing to note is that, all the method that opens a screen uses `showGeneralDialog` which does not modify the navigation stack. If you want, you may open the screen with navigation(routing) like `Navigator.of(context).push...()`.

See [WIDGETS.md](/doc/WIDGETS.md) for more widget example.
**Note:** you can use **`Theme()`** to style the widget

# Usage

Fireflutter updates in real time no matter what users do. Here are common uses of widgets and builders of each features.

## User

See [USER.md](/doc/USER.md) for details.

## Admin

See [ADMIN.md](/doc/ADMIN.md) for details.

## Chat

With FireFlutter you can easily create a customizable chat room.

<!-- ### Features
- Group Chat
- 1:1 Chat
- Image Upload
- Customizable Chat room -->

Display user's chats using [ChatService.instance](/doc/CHAT.md#chatservice) or if you're using `ChatRoomListView` you can use a controller [ChatRoomListViewController](/doc/CHAT.md#chat-room-list)

```dart
final controller = ChatRoomListViewController();
ChatRoomListView(
  controller: controller,
  singleChatOnly: false, // set true to display single (1:1) chat room
  itemBuilder: (context, room) => ChatRoomListTile(
    room: room,
    onTap: () {
      // ChatService.instance.showChatRoom(context:context);
      // you can use ChatRoomListViewController
      controller.showChatRoom(context: context,room: room);
    },
  ),
),
```

**_Go to [Chat.md](/doc/CHAT.md) for more feature builders and detailed explanation_**

## Post

See [POST.md](/doc/POST.md) for details.

## Comment

## Share

# Push notifications

See [PUSH_NOTIFICATION.md](/doc/PUSH_NOTIFICATION.md) for details.

# Error handling

There are some cases that you don't want to wait for the async work to be finished since it takes time to save data into the database. But you must show user if there is an error.

Then, you may use some code like below. It's waiting for the async to be finished and it displays error to user if there is any.

```dart
my.update(type: type).catchError(
  (e) => toast(
    title: 'Error',
    message: e.toString(),
  ),
);
```

# Admin

To set a user as an admin, put the user's uid into `isAdmin()` in [Firestore Security Rules](#firestore-security-rules).

```javascript
function isAdmin() {
  let adminUIDs = ["xxx", "oaCInoFMGuWUAvhqHE83gIpUxEw2"];
  return request.auth.uid in adminUIDs || request.auth.token.admin == true;
}
```

Then, set `isAdmin` to true in the user document.

**Features**

- [AdminService](doc/ADMIN.md#admin-service)
- [Admin Widgets](doc/ADMIN.md#admin-widgets)
- [Translation](doc/ADMIN.md#translation)
- [Unit Testing](doc/ADMIN.md#unit-testing)
- [Logic Test](doc/ADMIN.md#logic-test)

For more information, see [**ADMIN.md**](/doc/ADMIN.md).

# [Developers](doc/DEVELOPER.md#developer)

You can go to [Developer.md](/doc/DEVELOPER.md). This section gives a tips and detailed instruction on how to use the FireFlutter completely.

# Things to improve

- The follower's UIDs of A are saved in `followers` field of the all posts created by A.
  - If A has many followers like 10,000 followers, the size of the post document becomes very big. Saving posts in RTDB won't solve this issue since you cannot get posts that you're following. RTDB does not support for this search.
