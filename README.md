# FireFlutter

![FireFlutter](https://github.com/thruthesky/fireflutter/blob/main/doc/fireflutter_title_image.jpg?raw=true)

If you are looking for a package that help you develop a full featured content management app, then you have found a right one. FireFlutter is a free, open source, complete, rapid development package for creating apps like CMS(content management system), social service, chat, community(forum), shopping mall and much more based on Firebase.

Create an issue if you find a bug or need a help.
<br>
<br>
# Table of Contents {ignore=true}


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [FireFlutter](#fireflutter)
- [Overview](#overview)
- [Changes](#changes)
  - [Features](#features)
    - [Main Features](#main-features)
- [Getting started](#getting-started)
  - [Installation](#installation)
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
  - [Chat](#chat)
  - [User](#user)
  - [Post](#post)
  - [Comment](#comment)
  - [Share](#share)
- [Push notifications](#push-notifications)
- [Error handling](#error-handling)
- [Admin](#admin)
- [Developer Section](#developer-sectiondocdevelopermddeveloper)

<!-- /code_chunk_output -->

<!-- * [Overview](#overview)
* [Changes](#changes)
* [Features](#features)
  * [Main Features](#main-features)
* [Getting Started](#getting-started)
  * [Installation](#installation)
* [Firebase Extension](#firebase-extension)
  * [Resize image](#resize-image)
* [Install cloud functions](#install-cloud-functions)
* [Security Rules](#security-rules)
  * [Firestore](#firestore-security-rules)
  * [Admin](#security-rule-for-admin)
  * [Realtime Database](#realtime-database-security-rules)
* [Setup the base code](#setup-the-base-code)
* [Packages](#pubdev-packages)
  * [url_launcher](#url_launcher-optional)
  * [timeago](#timeago)
  * [Parsed_ReadMore](#parsed_readmore)
* [Build Sample](#build-sample)
  * [User Profile](#how-to-build-a-user-profile-page)
  * [Chat](#how-to-build-a-chat-app)
  * [Forum](#how-to-build-a-forum-app)
* [Usage](#usage)
  * [Users](#user)
  * [Post](#post)
  * [Comment](#comment)
  * [Chat](#chat)
  * [Share](#share)
* [Push Notification](#push-notifications)
* [Error Handling](#error-handling) -->

# Overview

Fireflutter made for reusing the common code blocks. Provides code for user, forum, chat and push notificiation management with `like`, `favorite`, `follow`, `post` and `comment` features.

There are some pre-defined fields for the user document. You can use `json_serializable` for providing each model extra fields.

The model has also basic CRUD functionalities.
# Changes
<!-- You can see [CHANGELOG.md](/CHANGELOG.md) for the updated log. -->

### Oct 10 0.3.12 {ignore=true}
* Refactoring on user, feed.
* Refine widgets and services.

### Sept 28 0.3.11 {ignore=true}
* Add. Admin dashboarsd.
* Update. Push notification.
* Refactoring. Save more data in realtime database.

### Sept 10 0.3.10 {ignore=true}

* Change. Refactoring file/folder names.

Go to [CHANGELOG.md](/CHANGELOG.md) for more.
<!-- paraphrased for readability, feel free to edit -->

<!-- I made it for reusing the most common code blocks when I am building apps. It provides the code for user management, forum(caetgory, post, comment) management, chat management, push notification management along with `like`, `favorite`, `following` features.

I use `json_serializable` for the modeling providing each model can have extra fields. For instance, there are some pre-defined fields for the user document and you may add your own fields on the document. The model has also basic CRUD functionalities. -->

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

<!-- Please follow the instructions below to install the fireflutter into your app. -->

### Create a Firebase

If you have your own firebase project, then you can use that. If you don't have one, create one first. Visit [Firebase Website](https://firebase.google.com).

<!-- ## Install the easy extension

We built a firebase extension for the easy management on firebase. FireFlutter is using this extension. Install the [latest version of easy-extension](https://github.com/thruthesky/easy-extension).
![easy_extension](/doc/img/easy_extension.png)

Choose Easy Extension version and it will redirect you to Firebase. Choose the project you want Easy Extension to be installed. -->

# Firebase Extension

<!-- Aside from `easy-extension`, you will need to install the following extensions -->

### Resize image

`Deletion of original file` - Don't delete  
`Make resized images public` - yes

![resize_image_settings](/doc/img/resize_option_1.png)

`Cache-Control header for resized images` - "max-age=86400"
`Convert image to preferred types` - select `webp` only.

![resize_image_settings](/doc/img/resize_option_2.png)

And choose `backfill` if you have an existing images.

![resize_image_settings](/doc/img/resize_option_3.png)

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

<!-- TODO: Firestore rule complete update -->

Copy [the security rules of fireflutter](https://raw.githubusercontent.com/thruthesky/fireflutter/main/firebase/firestore/firestore.rules) and paste it in your firebase project. You may need to copy only the parts of the necessary security rules.

<!--
TODO:
deploy rules on firebase using cli
 firebase deploy --only <name>.rules
 -->

### Security rule for admin

You can add your uid (or other user's uid) to the `adminUIDs` variable in `isAdmin` function in the security rule. With this way, you don't have to pay extra money for validating the user is admin or not.

```dart
function isAdmin() {
  let adminUIDs = ['root', 'admin', 'CYKk5Q79AmYKQEzw8A95UyEahiz1'];
  return request.auth.uid in adminUIDs || request.auth.token.admin == true;
}
```

After setting the admin, you can now customize your security rules to restrict some write access from other user. You can add sub-admin/s from client app without editing the security rules everytime.

<!-- Once the admin is set, you can customize your security rules to restrict some documents to write access from other users. By doing this way, you can add sub-admin(s) from client app (without editing the security rules on every time when you add subadmin) -->

For instance, you may write security rules like below and add the uids of sub-admin users. then, add a security rule function to check if the user is sub-admin.

```ts
  /settings/sub-admins {
    allow read, write: if isAdmin();
  }
  function isSubAdmin() {
    ...
  }
```

<!-- ### Admin settings

See the [Security rules for admin](#security-rule-for-admin) chapter to set admin in the security rules. After this, you can set the `isAdmin` field to true on the admin's user document. -->

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
    }
  }
}
```

<!-- Commented out -->
<!-- ### Security Rules for Stroage

You can copy this rules and paste into the rules of storage.

```json

``` -->

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

**Note:**
You don't have to initialize when you are only doing unit test.

<!-- Since, fireflutter uses `snackbars`, `dialog`, `bottom sheet`, it needs global key (or global build context). Put the global key into the `FireFlutterService.instance.init(context: ...)`. If you are not going to use the global key, you may not need to initialzie it like when you are only doing unit test. -->

**Note:**
If you meet an error like `No MaterialLocalizations found. Xxxx widgets require MaterialLocalizations to be provided by a Localizations widget ancestor.`, then you may think a widget is not under MaterialApp or no localization provided. In this case, the context from global key will be used. For more details, See <https://docs.flutter.dev/release/breaking-changes/text-field-material-localizations>.

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
![user_profile](/doc/img/user_profile.png)

### Chat App
Here is an example of how to build simple user profile page. 
![chat_app](/doc/img/chat_app.png)

### Forum App
<!-- FIXME: Not sure if I implemented this correctly -->
Here is a simple forum app. 
![forum_result](/doc/img/forum.png)

See [User Profile](/doc/SAMPLES.md#how-to-build-a-user-profile-page) for source code and detailed explanation.

# Widgets and UI functions

- The widgets in fireflutter can be a small piece of UI representation or it can be a full screen dialog.

- The file names and the class names of the widgets must match.
- The user widgets are inside `widgets/user` and the file name is in the form of `user.xxxx.dart` or `user.xxxx.dialog.dart`. And it goes the same to chat and forum.

- There are many service methods that opens a screen. One thing to note is that, all the method that opens a screen uses `showGeneralDialog` which does not modify the navigation stack. If you want, you may open the screen with navigation(routing) like `Navigator.of(context).push...()`.

See [WIDGETS.md](/doc/WIDGETS.md) for more widget example.
**Note:** you can use **`Theme()`** to style the widget

# Usage
Fireflutter updates in real time no matter what users do. Here are common uses of widgets and builders of each features.
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
***Go to [Chat.md](/doc/CHAT.md) for more feature builders and detailed explanation***
## User

See [USER.md](/doc/USER.md) for details.

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
# [Developer Section](doc/DEVELOPER.md#developer)

