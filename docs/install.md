# Install

Follow the instruction below to install Fireship into your app

## 1. Install Fireship

### Install Fireship as a package

Simply add the latest version of fireflutter from pub.dev

### Install Fireship as a package developer

You may wish to develop your app while building(or updating) the Fireship package together.

- Fork the Fireship from `https://github.com/thruthesky/fireflutter`

- Then, clone it

- Then, create a branch in Fireship local repository

- Create `apps` folder under the root of Fireship folder and create your app inside `apps` folder.

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

- If you have update any code in Fireship, consider to submit a `pull request`.

## 2. Install Firebase Database Secuirty

If you have your own firebase project, then you can use that. Or you can create one.

Refer to this reference: <https://firebase.google.com/docs/flutter/setup>

### Add the security rule for RTDB

<!-- TODO must have security rule -->

## Default app-environment entitlement

Add the following code into `info.plist`.

```xml
<key>NSCameraUsageDescription</key>
<string>PhiLov app requires access to the camera to share the photo on profile, chat, forum.</string>
<key>NSMicrophoneUsageDescription</key>
<string>PhiLov app requires access to the microphone to share vioce with other users.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>PhiLov app requires access to the photo library to share the photo on profile, chat, forum.</string>
```

## Install Cloud Functions

Run the following command to install `sendPushNotifications` cloud function.

```sh
% npm run deploy:sendPushNotifications
```

And set the end point URL to `MessagingService.instance.init(sendPushNotificationsUrl: ..)`

## Setup the base code

Fireship needs the app to initialize with the Firebase before using it.

Do the settings to connect to firebase.

```cmd
flutterfire configure
```

Add firebase dependencies

```cmd
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

## Admin

- See [Admin Doc](admin.md)
