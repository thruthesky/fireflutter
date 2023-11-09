# Overview of FireFlutter


![FireFlutter](https://github.com/thruthesky/fireflutter/blob/main/doc/fireflutter_title_image.jpg?raw=true)

If you are looking for a package that help you develop a full featured content management app, then you have found a right one. FireFlutter is a free, open source, complete, rapid development package for creating apps like CMS(content management system), social service, chat, community(forum), shopping mall and much more based on Firebase.

Create an issue if you find a bug or need a help.


## Overview

The goal of FireFlutter is to provide the reusable common code blocks encapsulating in the widgets. So, developer can quickly develop what they want using this package.

It provides code for user, forum, chat and push notificiation management that works with `like`, `favorite`, `follow`, `post` and `comment` features.

There are some pre-defined fields for the common usage in the database structure. We use `json_serializable` for providing each model with the fields.

The model has also basic CRUD functionalities.



### The principles

#### DRY

To not repeat ourselves, we made the commonly reused code modulized as much as possible. The concept here is that we should not write the same code twice.




#### Abstraction

We made abstractions and the logic gets complicated and the code gets long.


#### Don't make it a function

It should be a class method or a widget instead of a plain function except the handy alias functions that simple wrap the class method or widget.




## Changes

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

## Getting started

To get started, you can follow the [Installation](#installation) chapter.

The best way is to copy codes from the example project and paste it into your project and update the UI.


## Pub.dev Packages

### url_launcher (Optional)

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

### timeago

Converts date into a humanized text.

```dart
    final fifteenAgo = DateTime.now().subtract(Duration(minutes: 15));

    print(timeago.format(fifteenAgo)); // 15 minutes ago
    print(timeago.format(fifteenAgo, locale: 'en_short')); // 15m
    print(timeago.format(fifteenAgo, locale: 'es')); // hace 15 minutos
```

Visit [timeago](https://pub.dev/packages/timeago) to read more.

### Parsed_ReadMore

Allows the text to collapsed or expanded and automatically parse the url text to hyperlinks.

Visit [parsed_readmore](https://pub.dev/packages/parsed_readmore) to read more.

<!-- TODO: -->

## Build Sample

### User Profile Page

Here is an example of how to build simple user profile page.
![user_profile](https://github.com/thruthesky/fireflutter/blob/main/doc/img/user_profile.png?raw=true)

### Chat App

Here is an example of how to build simple user profile page.
![chat_app](doc/img/chat_app.png)

### Forum App

<!-- FIXME: Not sure if I implemented this correctly -->

Here is a simple forum app.
![forum_result](doc/img/forum.png)

See [User Profile](https://github.com/thruthesky/fireflutter/blob/main/doc/SAMPLES.md#how-to-build-a-user-profile-page?raw=true) for source code and detailed explanation.

## Widgets and UI functions

- The widgets in fireflutter can be a small piece of UI representation or it can be a full screen dialog.

- The file names and the class names of the widgets must match.
- The user widgets are inside `widgets/user` and the file name is in the form of `user.xxxx.dart` or `user.xxxx.dialog.dart`. And it goes the same to chat and forum.

- There are many service methods that opens a screen. One thing to note is that, all the method that opens a screen uses `showGeneralDialog` which does not modify the navigation stack. If you want, you may open the screen with navigation(routing) like `Navigator.of(context).push...()`.

See [WIDGETS.md](doc/WIDGETS.md) for more widget example.
**Note:** you can use **`Theme()`** to style the widget

## Usage

Fireflutter updates in real time no matter what users do. Here are common uses of widgets and builders of each features.


### User


See [USER.md](doc/USER.md) for details.


### Admin


See [ADMIN.md](doc/ADMIN.md) for details.

<!-- Will make all helpers looks like the Chat -->

### Chat

With FireFlutter you can easily create a customizable chat room.

<!-- ### Features
- Group Chat
- 1:1 Chat
- Image Upload
- Customizable Chat room -->

Display user's chats using [ChatService.instance](doc/CHAT.md#chatservice) or if you're using `ChatRoomListView` you can use a controller [ChatRoomListViewController](doc/CHAT.md#chat-room-list)

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

**_Go to [Chat.md](doc/CHAT.md) for more feature builders and detailed explanation_**

### Post

See [POST.md](doc/POST.md) for details.

### Comment

See [COMMENT.md](doc/COMMENT.md) for details.

### Share

See [SHARE.md](doc/SHARE.md) for details.

### Test

See [TEST.md](doc/TEST.md) for details.

### Functions

See [FUNCTIONS.md](doc/FUNCTIONS.md) for details.

### Widgets

See [WIDGETS.md](doc/WIDGETS.md) for details.



## Push notifications

See [PUSH_NOTIFICATION.md](doc/PUSH_NOTIFICATION.md) for details.

### Error handling

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

### Admin

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

For more information, see [ADMIN.md](doc/ADMIN.md).

## [Developers](doc/DEVELOPER.md#developer)

You can go to [Developer.md](doc/DEVELOPER.md). This section gives a tips and detailed instruction on how to use the FireFlutter completely.

## Things to improve

- The follower's UIDs of A are saved in `followers` field of the all posts created by A.
  - If A has many followers like 10,000 followers, the size of the post document becomes very big. Saving posts in RTDB won't solve this issue since you cannot get posts that you're following. RTDB does not support for this search.
