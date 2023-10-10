# FireFlutter

![FireFlutter](https://github.com/thruthesky/fireflutter/blob/main/doc/fireflutter_title_image.jpg?raw=true)

If you are looking for a package that help you develop a full featured content management app, then you have found a right one. FireFlutter is a free, open source, complete, rapid development package for creating apps like CMS(content management system), social service, chat, community(forum), shopping mall and much more based on Firebase.

Create an issue if you find a bug or need a help.

# Changes
You can see [CHANGELOG.md](/CHANGELOG.md) for the updated log.

- Oct 10, Refactoring on user, feed.
- Oct 6, easy-extension was removed.
- Oct 8, Test app was added. you can add it in apps folder. <https://github.com/thruthesky/fireflutter_test> See TestUi Widget

# Overview

Fireflutter made for reusing the common code blocks. Provides code for user, forum, chat and push notificiation management with `like`, `favorite`, `follow`, `post` and `comment` features.

There are some pre-defined fields for the user document. You can use `json_serializable` for providing each model extra fields.

The model has also basic CRUD functionalities.

<!-- paraphrased for readability, feel free to edit -->

<!-- I made it for reusing the most common code blocks when I am building apps. It provides the code for user management, forum(caetgory, post, comment) management, chat management, push notification management along with `like`, `favorite`, `following` features.

I use `json_serializable` for the modeling providing each model can have extra fields. For instance, there are some pre-defined fields for the user document and you may add your own fields on the document. The model has also basic CRUD functionalities. -->

## Features

There are many features and most of them are optional. You may turn on the extra functions by the setting.

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

## Create a Firebase

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

# Pub.dev Packages

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

# How to build a user profile page
Here is an example of how to build simple user profile page. See [SAMPLE.md](/doc/SAMPLES.md#how-to-build-a-user-profile-page) for source code and detailed explanation.

![user_profile](/doc/img/user_profile.png)

# How to build a chat app
Here is an example of how to build simple user profile page. See [SAMPLE.md](/doc/SAMPLES.md#how-to-build-a-chat-app) for source code and detailed explanation.

![chat_app](/doc/img/chat_app.png)

# How to build a forum app

Here is a simple forum app. See [SAMPLE.md](/doc/SAMPLES.md#how-to-build-a-forum-app) for source code and detailed explanation.
![forum_result](/doc/img/forum.png)

<!-- FIXME: Not sure if I implemented this correctly -->


# Usage

## UserService

<!-- #section removed
  reason: documentNotExistBuilder has been removed

In this case, the `documentNotExistBuilder` of `UserDoc` will be called.

So, the lifecyle will be the following when the app users `UserDoc`.

- `UserService.instance.nullableUser` will have an instance of `User`
  - If the user document does not exists, `exists` will be `false` causing `documentNotExistsBuilder` to be called.
  - If the user document exist, then it will have right data and `builder` will be called. -->

`UserService.instance.nullableUser` is _null_ when

- on app boot
- the user don't have documents
- when user has document but `UserService` has not read the user document yet.

<!-- **Note:** Use ***async*** to wait UserService to load the data -->

`UserService.instance.nullableUser.exists` is _null_ if the user has logged in but no document.

The `UserService.instance.user` or `UserService.instance.documentChanges` may be null when the user document is being loaded on app boot. So, the better way to get the user's document for sure is to use `UserService.instance.get`

Right way of getting a user document.

```dart
UserService.instance.get(myUid!).then((user) => ...);
```

You cannot use `my` until the UserService is initialized and `UserService.instance.user` is available. Or you will see `null check operator used on a null value.`

<!-- .customize does not exist[???],

TODO: Learning it more so i can replace it

  might remove since there is already a section of Post Below
-->

<!-- ## PostService

### How to open a post
Call the `showPostViewScreen` to show the full screen dialog that displays the post

```dart
PostService.instance.customize.postViewScreenBuilder = (post) => GRCCustomPostViewScreen(post: post);
```

### Customizing a Post View

Build your own UI design of the full screen Post View like below.

```dart
PostService.instance.customize.postViewScreenBuilder = (post) => GRCCustomPostViewScreen(post: post);
```

The widget is preferrably a full screen widget. It can be a scaffold, sliver, etc. -->

## PostService

If `enableNotificationOnLike` is set to true, then it will send push notification to the author when there is a like. You would do the work by adding `onLike` callback.

```dart
PostService.instance.init(
  onLike: (Post post, bool isLiked) async {
    if (!isLiked) return;
    MessagingService.instance.queue(
      title: post.title,
      body: "${my.name} liked your post.",
      id: myUid,
      uids: [post.uid],
      type: NotificationType.post.name,
    );
  },
  // When it is set to true, you don't have add `onLike` callback to send push notification.
  enableNotificationOnLike: true,
```

## CommentService

You can customize the `showCommentEditBottomSheet` how to comment edit(create or update) box appears.

The code below simply call `next()` function which does exactly the same as the default logic from `fireflutter`.

```dart
CommentService.instance.init(
  customize: CommentCustomize(
    showCommentEditBottomSheet: (
      BuildContext context, {
      Comment? comment,
      required Future<Comment?> Function() next,
      Comment? parent,
      Post? post,
    }) {
      return next();
    },
  ),
);
```

You may add some custom code like below.

```dart
CommentService.instance.init(
  customize: CommentCustomize(
    showCommentEditBottomSheet: (
      BuildContext context, {
      Comment? comment,
      required Future<Comment?> Function() next,
      Comment? parent,
      Post? post,
    }) {
      if (my.isComplete == false) {
        warning(context, title: '본인 인증', message: '본인 인증을 하셔야 댓글을 쓸 수 있습니다.');
        return Future.value(null);
      }
      return next();
    },
  ),
);
```

Or you can do the UI/UX by yourself since it delivers everything you need to show comment edit box.

## ChatService

### How to open 1:1 chat room

Use the `showChatRoom` method anywhere with user model.

```dart
ChatService.instance.showChatRoom(context: context, user: user);
```

### How to display chat room menu

Since all app have different features and design, you can customize or rebuild it. See the code below and paste them into your project.

<!-- By default, it has a full screen dialog with default buttons. Since all apps have difference features and design, you will need to customize it or rebuild it. But see the code inside and copy and paste them into your project. -->
<!-- body: ChatRoomMenuUserInviteDialog(room: room), -->

How to show chat room dialog.

```dart
showGeneralDialog(
  context: context,
  pageBuilder: (context, _, __) => Scaffold(
    appBar: AppBar(
      title: const Text('Invite User'),
    ),
    body: CustomChatWidget(),
  ),
);
```

### Customizing the chat header

You can build your own chat header like below.

```dart
ChatService.instance.customize.chatRoomAppBarBuilder = (room) => MomCafeChatRoomAppBar(room: room);
```

# Widgets and UI functions

- The widgets in fireflutter can be a small piece of UI representation or it can be a full screen dialog.

- The file names and the class names of the widgets must match.
- The user widgets are inside `widgets/user` and the file name is in the form of `user.xxxx.dart` or `user.xxxx.dialog.dart`. And it goes the same to chat and forum.

- There are many service methods that opens a screen. One thing to note is that, all the method that opens a screen uses `showGeneralDialog` which does not modify the navigation stack. If you want, you may open the screen with navigation(routing) like `Navigator.of(context).push...()`.

See [WIDGETS.md](/doc/WIDGETS.md) for more widget example.
**Note:** you can use **`Theme()`** to style the widget



# Chat Features
See [CHAT.md](/doc/CHAT.md) for details.

# User

See [USER.md](/doc/USER.md) for details.



# Post
See [POST.md](/doc/POST.md) for details.



# Push notifications
See [PUSH_NOTIFICATION.md](/doc/PUSH_NOTIFICATION.md) for details.

# Services

## ShareService

ShareService is a helper library that gives some feature untility for sharing. It has `showBotomSheet` method that displays a bottom sheet showing some UI elements for sharing. You may get an idea seeing the look and the code of the method.

It also has a method `dyamicLink` that returns a short dyanmic link. You may see the source code of the method to get an insight how you would copy and paste in your project.

```dart
Share.share(
  await ShareService.instance.dynamicLink(
    link: "https://xxx.page.link/?type=feed&id=${post.id}",
    uriPrefix: "https://xxx.page.link",
    appId: "com.xxx.xxx",
    title: post.title,
    description: post.content.upTo(255),
  ),
  subject: post.title,
);
```

Often, the `dynamicLink` method is called deep inside the widget tree. So, we provide a customization for building dynmaic links. You can set the `uriPrefix` and the `appId`. And the fireflutter will use this setting to generator custom build.

```dart
ShareService.instance.init(
  uriPrefix: "https://xxx.page.link",
  appId: "xxx.xxx.xxx",
);
```

When the dyanmic link is build, it has one of the `type` between `user`, `post`. When it is a `user`, you may show the user's profile. If it is `post`, you may show the post. We don't support the link for `chat` yet. Because the user needs to register first before entering the chat room while user profile and post view can be seen without login. But we are planning to support for `chat` link soon.

Dispaly a share bottom sheet.

```dart
ShareService.instance.showBottomSheet(actions: [
  IconTextButton(
    icon: const Icon(Icons.share),
    label: "Share",
    onTap: () async {
      Share.share(
        await ShareService.instance.dynamicLink(
          link: "https://xxxx.page.link/?type=xxx&id=xxx",
          uriPrefix: "https://xxxx.page.link",
          appId: "xxx",
          title: 'title',
          description: 'description..',
        ),
        subject: 'subject',
      );
    },
  ),
  IconTextButton(
    icon: const Icon(Icons.copy),
    label: "Copy Link",
    onTap: () {},
  ),
  IconTextButton(
    icon: const Icon(Icons.comment),
    label: "Message",
    onTap: () {},
  ),
]),
```

Example of copying the dynamic link to clipboard

```dart
IconTextButton(
  icon: const Icon(Icons.copy),
  label: "Copy Link",
  onTap: () async {
    final link = await ShareService.instance.dynamicLink(
      type: DynamicLink.post.name,
      id: 'post.id',
      title: 'title',
      description: 'description..',
    );
    Clipboard.setData(ClipboardData(text: link));
    toast(title: tr.copyLink, message: tr.copyLinkMessage);
  },
),
```

Below is an example of how to use `ShareBottomSheet` widget. You can insert this widget in home screen and do some UI work. Then, apply it.

```dart
ShareBottomSheet(actions: [
  IconTextButton(
    icon: const Icon(Icons.share),
    label: "Share",
    onTap: () async {
      Share.share(
        await ShareService.instance.dynamicLink(
          type: DynamicLink.feed.name,
          id: 'post.id',
          title: 'title',
          description: 'description..',
        ),
        subject: 'subject',
      );
    },
  ),
  IconTextButton(
    icon: const Icon(Icons.copy),
    label: "Copy Link",
    onTap: () async {
      final link = await ShareService.instance.dynamicLink(
        type: DynamicLink.post.name,
        id: 'post.id',
        title: 'title',
        description: 'description..',
      );
      Clipboard.setData(ClipboardData(text: link));
      toast(title: tr.copyLink, message: tr.copyLinkMessage);
    },
  ),
  IconTextButton(
    icon: const Icon(Icons.comment),
    label: "Message",
    onTap: () async {
      final link = await ShareService.instance.dynamicLink(
        type: DynamicLink.post.name,
        id: 'post.id',
        title: 'title',
        description: 'description..',
      );
      final re = await launchSMS(phnumber: '', msg: link);
      if (re) {
        toast(title: 'SMS', message: 'Link sent by SMS');
      } else {
        toast(title: 'SMS', message: 'Cannot open SMS');
      }
    },
  ),
]),
```
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

To set a user as an admin, put the user's uid into `isAdmin()` in firestore security rules.

```javascript
function isAdmin() {
  let adminUIDs = ["xxx", "oaCInoFMGuWUAvhqHE83gIpUxEw2"];
  return request.auth.uid in adminUIDs || request.auth.token.admin == true;
}
```

Then, set `isAdmin` to true in the user document.

## Admin Widgets

### Opening admin dashbard

To open admin dashboard, call `AdminService.instance.showDashboard()`.

```dart
AdminService.instance.showDashboard(context);
```

Or you may want to open with your own code like below

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (c) => const AdminDashboardScreen()),
);
```

### AdminUserListView

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

- `SYNC_CUSTOM_CLAIMS` option only works with `update_custom_claims` command.
  - When it is set to `yes`, the claims of the user will be set to user's document.
  - By knowing user's custom claims,
    - the app can know that if the user is admin or not.
      - If the user is admin, then the app can show admin menu to the user.
    - Security rules can work better.

### Disable user

- Disabling a user means that they can't sign in anymore, nor refresh their ID token. In practice this means that within an hour of disabling the user they can no longer have a request.auth.uid in your security rules.

  - If you wish to block the user immediately, I recommend to run another command. Running `update_custom_claims` comand with `{ disabled: true }` and you can add it on security rules.
  - Additionally, you can enable `set enable field on user document` to yes. This will add `disabled` field on user documents and you can search(list) users who are disabled.

- `SYNC_USER_DISABLED_FIELD` option only works with `disable_user` command.

  - When it is set to yes, the `disabled` field with `true` will be set to user document.
  - Use this to know if the user is disabled.

- Request

```ts
{
  command: 'delete_user',
  uid: '--user-uid--',
}
```

<!-- - Warning! Once a user changes his displayName and photoUrl, `EasyChat.instance.updateUser()` must be called to update user information in easychat. -->

# Translation

The text translation for i18n is in `lib/i18n/i18nt.dart`.

By default, it supports English and you can overwrite the texts to whatever language.

Below show you how to customize texts in your language. If you want to support multi-languages, you may overwrite the texts on device language.

```dart
TextService.instance.texts = I18nTexts(
  reply: "답변",
  loginFirstTitle: '로그인 필요',
  loginFirstMessage: '로그인을 해 주세요.',
  roomMenu: '채팅방 설정',
  noChatRooms: '채팅방이 없습니다. 채팅방을 만들어 보세요.',
  chooseUploadFrom: "업로드할 파일(또는 사진)을 선택하세요.",
  dismiss: "닫기",
  like: '좋아요',
  likes: '좋아요(#no)',
  favorite: "즐겨찾기",
  unfavorite: "즐겨찾기해제",
  favoriteMessage: "즐겨찾기를 하였습니다.",
  unfavoriteMessage: "즐겨찾기를 해제하였습니다.",
  chat: "채팅",
  report: "신고",
  block: "차단",
  unblock: "차단해제",
  blockMessage: "차단 하였습니다.",
  unblockMessage: "차단 해제 하였습니다.",
  alreadyReportedTitle: "신고",
  alreadyReportedMessage: "회원님께서는 본 #type을 이미 신고하셨습니다.",
);
```

You can use the language like below,

```dart
 Text(
  noOfLikes == null
      ? tr.like
      : tr.likes.replaceAll(
          '#no', noOfLikes.length.toString()),
```

# Unit Testing

## Testing on Local Emulators and Firebase

- We do unit testing on both of local emulator and on real Firebase. It depends on how the test structure is formed.

## Testing security rules

Run the firebase emulators like the followings. Note that you will need to install and setup emulators if you didn't.

```sh
cd firebase/firestore
firebase emulators:start
```

Then, run all the test like below.

```sh
npm test
```

To run group of tests, specify folder name.

```sh
npm run mocha tests/rule-functions
npm run mocha tests/posts
```

To run a single test file, specify file name.

```sh
npm run mocha tests/posts/create.spec.js
npm run mocha tests/posts/likes.spec.js
```

## Testing on real Firebase

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

## Testing on Cloud Functions

All of the cloud functions are tested directly on remote firebase (not in emulator). So, you need to save the account service in `firebase/service-account.json`. The service account file is listed in .gitignore. So, It won't be added into git.

To run all the test,

```sh
cd firebase/functions
npm i
run test
```

To run a single test,

```sh
npm run mocha **/save-token*
npm run mocha **/save-token.test.ts
```

# Logic test

To test the functionality of fireflutter, it needs a custom way of testing. For instance, fireflutter listens user login and creates the user's document if it does not exists. And what will happen if the user document is deleted by accident? To prove that there will be no bug on this case, it need to be tested and the test must work based on the real firebase events and monitor if the docuemnt is being recreated. Unit test, widget test and integration test will not work for this.

We wrote some test code and saved it in `TestUi` widget. To run the test in `TestUi`, you will need to initialize firebase. But don't initialize fireflutter nor other services in fireflutter.


## TestUi Widget

This has custom maid test code for fireflutter. You may learn more teachniques on using fireflutter by seeing the test code.



# Developer

In this chapter, you will learn how to develop fireflutter. You would also continue developing your app while developing(fixing) the fireflutter.

## Installing your app with fireflutter

- Fork the fireflutter
  - Go to `https://github.com/thruthesky/fireflutter` and fork it.
- Then, clone it
  - `git clone https://github.com/your-account/fireflutter`.
- Create a branch in fireflutter local repository
  - `cd fireflutter`
  - `git checkout -b work`
- For `Pull Request`, update any file, commit, push and request for pulling your code.
  - `echo "Hi" >> README.md`
  - `git commit -a -m "updating README.md"`
  - `git push --set-upstream origin work`
- Create `apps` folder and create your app inside `apps` folder.

  - `cd apps`
  - `flutter create your_porject`

- Since your project add the fireflutter from your computer folder, you need to add the path of the dependency as `../..`. Add the firefluter dependenicy like below.

```yaml
dependencies:
  fireflutter:
    path: ../..
```

- Then, follow the step of the [fireflutter Installation](#installation) chapter.

## Development Tips

Most often, you would click, and click, and click over, and over again, and again to see what you have changed on the UI. Then, you change the UI again. And you would click, and click over again, and again, ...
Yes, this is the reality.

To avoid this, you can display the UI part immediately after hot-restart (with keyboard shortcut) like below. This is merely a sample code. You can test any part of the app like below.

Below is an example of openning a chat room

```dart
ChatService.instance.showChatRoom(
  context: context,
  room: await Room.get('hQnhAosriiewigr4vWFx'),
);
```

Below is an example of openning a group chat room menu dialog.
I copied the `Room` properties manually from the Firestore document and I edited some of the values of the properties for test purpose. You may code a line to get the real room model data.

```dart
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 200), () {
      ChatService.instance.openChatRoomMenuDialog(
        context: context,
        room: Room(
          id: 'DHZWDyeuAlgmKxFxbMbF',
          name: 'Here we are in Manila. Lets celebrate this beautiful day.',
          group: true,
          open: true,
          master: 'ojxsBLMSS6UIegzixHyP4zWaVm13',
          users: [
            '15ZXRtt5I2Vr2xo5SJBjAVWaZ0V2',
            '23TE0SWd8Mejv0Icv6vhSDRHe183',
            'JAekM4AyPTW1fD9NCwqyLuBCTrI3',
            'X5ps2UhgbbfUd7UH1JBoUedBzim2',
            'lyCxEC0oGtUcGi0KKMAs8Y7ihSl2',
            'ojxsBLMSS6UIegzixHyP4zWaVm13',
            'aaa', // not existing user
            't1fAVTeN5oMshEPYn9VvB8TuZUy2',
            'bbb', // not existing user
            'ccc', // not existing user
            'ddd', // not existing user
            'eee', // not existing user
          ],
          moderators: ['lyCxEC0oGtUcGi0KKMAs8Y7ihSl2', '15ZXRtt5I2Vr2xo5SJBjAVWaZ0V2'],
          blockedUsers: [],
          noOfNewMessages: {},
          maximumNoOfUsers: 3,
          rename: {
            FirebaseAuth.instance.currentUser!.uid: 'I renamed this chat room',
          },
          createdAt: Timestamp.now(),
        ),
      );
```

Below is an example of opening a single chat room. I got the room data by calling `print` on a chat room.

```dart
ChatService.instance.showChatRoom(
  context: context,
  room: Room(
    id: '23TE0SWd8Mejv0Icv6vhSDRHe183-ojxsBLMSS6UIegzixHyP4zWaVm13',
    name: '',
    group: false,
    open: false,
    master: '23TE0SWd8Mejv0Icv6vhSDRHe183',
    users: ['23TE0SWd8Mejv0Icv6vhSDRHe183', 'ojxsBLMSS6UIegzixHyP4zWaVm13'],
    rename: {},
    moderators: [],
    maximumNoOfUsers: 2,
    createdAt: Timestamp.now(),
    blockedUsers: [],
  ),
);
```

Below is to show post view screen. Since apps do routings differently, we can use onPressedBackButton to go to the proper screen.

```dart
/// Example 1
Post.get('Uc2TKInQ9oBJeKtSJpBq').then((p) => PostService.instance.showPostViewScreen(context: context, post: post, onPressedBackButton: () {
  context.go(RouterLogic.go('My Home'));
}));
```

Below is to show post edit dialog.

```dart
Post.get('Uc2TKInQ9oBJeKtSJpBq').then((p) => PostService.instance.showPostEditDialog(context, post: p));
```

The code below shows how to open a post create dialog.

```dart
PostService.instance.showCreateDialog(
  context,
  categoryId: 'buyandsell',
  success: (p) => print(p),
);
```

The code below shows how to open a 1:1 chat room and send a message to the other user.

```dart
UserService.instance.get(UserService.instance.adminUid).then(
  (user) async {
    ChatService.instance.showChatRoom(context: context, user: user);
    ChatService.instance.sendMessage(
      room: await ChatService.instance.getSingleChatRoom(UserService.instance.adminUid),
      text: "https://naver.com",
    );
  },
);
```

The code below shows how to open a comment edit bottom sheet. Use this for commet edit bottom sheet UI.

```dart
PostService.instance.showPostViewScreen(context, await Post.get('PoxnpxpcC2lnYv0jqI4f'));
if (mounted) {
  CommentService.instance.showCommentEditBottomSheet(
    context,
    comment: await Comment.get('bvCJk4RFK79yexAKfAYs'),
  );
}
```

# Contribution

Fork the fireflutter and create your own branch. Then update code and push, then pull request.

## Install FireFlutter and Example Project

```sh
git clone https://github.com/thruthesky/fireflutter
cd fireflutter
mkdir apps
cd apps
git clone https://github.com/thruthesky/example
cd example
flutter run
```

## Coding Guideline

fireflutter uses sigular form in its file name and variable name, class name. For instance, it alwasy `user` over `users` unless there is good reason.
