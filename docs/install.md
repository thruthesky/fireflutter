
# Installation

Follow the instruction below to install FireFlutter into your app

## Install FireFlutter as a package

Not much here. Just add the latest version of fireflutter from pub.dev

## Install FireFlutter as a package developer

You may wish to develop your app while building(or updating) the fireflutter pakcage together.

- Fork the fireflutter from `https://github.com/thruthesky/fireflutter`


- Then, clone it

- Then, create a branch in fireflutter local repository

- Create `apps` folder under the root of fireflutter folder and create your app inside `apps` folder.

```dart
mkdir apps
cd apps
flutter create your_project
```

- You need to add the path of the dependency as `../..`. Add the firefluter dependency like below.

```yaml
dependencies:
  fireflutter:
    path: ../..
```


- If you have update any code in FlutterFlow, consider to submit a `pull request`.


## Create a Firebase

If you have your own firebase project, then you can use that. Or you can create one.

## Firebase Extension


### Resize image

Flutterflow uses thumbnails. And you must provide it with the resize image extension.

There are the options for the resize image extension.

`Sizes of resized images` - 200x200

`Deletion of original file` - Don't delete  
`Make resized images public` - yes

`Cache-Control header for resized images` - "max-age=86400"
`Convert image to preferred types` - select `webp` only.

`Backfill existing images` - Yes. Choose `backfill` if you have an existing images.

All other options are on your choice.

To display the thumbnail image, you may use `.thumbnail` String extension method. `CachedNetworkImage(imageUrl: url.thumbnail)`


## Install cloud functions

```sh
git clone https://github.com/thruthesky/fireflutter
cd fireflutter/firebase/functions
npm i
firebase use --add <project>
npm run deploy
```

Note that, you cannot develope push notifications with Firebase Extension. That's why we are using cloud functions.


Note, if you see error like `v2 function name(s) can only contain lower case letters, numbers, hyphens, and not exceed 62 characters in length`, then install the latest version of npm, nodejs, firebase.


Note, if you see warnings like `functions: Since this is your first time using 2nd gen functions, we need a little bit longer to finish setting everything up. Retry the deployment in a few minutes.`, then take 5 minutes break and re-deploy.


## Security rules

You need to install security rules for Firestore, Realtime Database, Storage.

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
    }
  }
}
```

## APN - iOS Push Notification Setting

- Do `Upload APNs auth key` in Firebase console.
- Enable the following by adding Capabilties in Xcode.
  - Push Notifications
  - `Background fetch` and `Remote notification` of Background Mode


## Default app-environment entitlement

```xml
<key>NSCameraUsageDescription</key>
<string>PhiLov app requires access to the camera to share the photo on profile, chat, forum.</string>
<key>NSMicrophoneUsageDescription</key>
<string>PhiLov app requires access to the microphone to share vioce with other users.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>PhiLov app requires access to the photo library to share the photo on profile, chat, forum.</string>
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
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      FireFlutterService.instance.init(
        context: () => router.routerDelegate.navigatorKey.currentContext!,
      );
  }
}
```

FireFlutter has many features and each feature has a singleton service class. You need to initialize each of the singleton on your needs.

FireFlutter needs **Global Key** since it uses `snackbars`, `dialog`, `bottom sheet`. Use the **`FireFlutterService.instance.init(context : ...)`**

Note, you don't have to initialize when you are only doing unit test.

Note, if you meet an error like `No MaterialLocalizations found. Xxxx widgets require MaterialLocalizations to be provided by a Localizations widget ancestor.`, then you may think a widget is not under MaterialApp or no localization provided. In this case, the context from global key will be used. For more details, See <https://docs.flutter.dev/release/breaking-changes/text-field-material-localizations>.

For instance, if you are using [go_route package](https://pub.dev/packages/go_router), you can pass the global build context like below.

```dart
//  initialize admin
UserService.instance.init(adminUid: 'xxx');

WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  FireFlutterService.instance.init(context: () => router.routerDelegate.navigatorKey.currentContext!);
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

By default, the feed feature is disabled. To use feed features, add the following in app widget.

```dart
FeedService.instance.init(enable: true);
```


If you have difficulty to install the fireflutter, please create an issue for help.
