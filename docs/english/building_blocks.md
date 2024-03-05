# Building Blocks

This document explains how to build an app by using basic widgets provided by Fireflutter, assembling them like building blocks. Of course, you can also copy the source code of these basic widgets and modify them to create your own custom widgets.

## Error Handling

In Fireflutter, widgets or logic may sometimes raise exceptions. Some of these exceptions are not handled internally by Fireflutter, meaning they need to be handled within the app.

Some widget may throw exception without any handler. Error handling within the app is typically done using the `runZoneGuarded` method. It is recommended to set global error handler to catch all unhandled exceptions.

Example:

```dart
runZonedGuarded(
    () async {
      runApp(const MyApp());
      /// Flutter error happens here like Overflow, Unbounded height
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
      };
    },
    zoneErrorHandler,
  );
  zoneErrorHandler(error, stackTrace) {
    print("----> runZoneGuarded() : exceptions outside flutter framework.");
    print("---> runtimeType: ${error.runtimeType}"); 
    if (error is FirebaseAuthException) {
      if (AppService.instance.smsCodeAutoRetrieval) {
        if (error.code.contains('session-expired') ||
            error.code.contains('invalid-verification-code')) {
          print("....");
          return;
        }
      } else {}

      toast(
          context: context,
          message: 'Error :  ${error.code} - ${error.message}');
    } else if (error is FirebaseException) {
      print("FirebaseException :  $error }");
    } else {
      print("Unknown Error :  $error");
      // toast(context: context, message: "백엔드 에러 :  ${error.code} - ${error.message}");
    }
    debugPrintStack(stackTrace: stackTrace);
  }
```

## Multilingual Support

To enable multilingual support on iOS, you need to add the following to your `Info.plist` file:

```xml
 <key>CFBundleLocalizations</key>
 <array>
  <string>en</string>
  <string>ko</string>
 </array>
```

Furthermore, within the app, configure language settings and set the language for each country in `TextService.instance.texts`.

```dart
// 아래와 같이 원하는 언어를 추가하고,
TextService.instance.texts = {
  ...TextService.instance.texts,
    'login': systemLanguageCode == 'ko' ? '로그인' : 'Login',
};

// 아래아 같이 쓰면 된다.
Text('login'.tr);
```

## Login-Related Widgets

### SimpleEmailPasswordLoginForm

It provides basic email and password login functionality. You can copy and modify the source code of this widget to use it.

```dart
return SimpleEmailPasswordLoginForm(
    onLogin: () async {
        // some login logic here
    },
    onRegister: () async {
        // some register logic here
    },
);
```

### SimplePhoneSignIn

It provides basic phone number login functionality.

Example:

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('전화번호 로그인'),
  ),
  body: Padding(
    padding: const EdgeInsets.all(lg),
    child: SimplePhoneSignIn(
      emailLogin: true,
      reviewEmail: Config.reviewEmail,
      reviewPassword: Config.reviewPassword,
      reviewPhoneNumber: Config.reviewPhoneNumber,
      reviewRealPhoneNumber: Config.reviewRealPhoneNumber,
      reviewRealSmsCode: Config.reviewRealSmsCode,
      onCompleteNumber: (value) {
        String number = value.trim();
        number = number.replaceAll(RegExp(r'[^\+0-9]'), '');
        number = number.replaceFirst(RegExp(r'^0'), '');
        number = number.replaceAll(' ', '');

        if (number.startsWith('10')) {
          return '+82$number';
        } else if (number.startsWith('9')) {
          return '+63$number';
        } else
        // 테스트 전화번호
        if (number.startsWith('+1')) {
          return number;
        } else if (number == Config.reviewPhoneNumber) {
          return number;
        } else {
          error(
              context: context,
              title: '에러',
              message:
                  '에러\n한국 전화번호 또는 필리핀 전화번호를 입력하세요.\n예) 010 1234 5678 또는 0917 1234 5678');
          throw '전화번호가 잘못되었습니다. 숫자만 입력하세요.';
        }
      },
      onSignin: () {
        context.pop();
        context.go(HomeScreen.routeName);
      },
    ),
  ),
);
```

## Chat widgets

Whatever app that has the chat feature has common screens and widgets.

### Chat room list

To list chat rooms that the login user joined, use `DefaultChatRoomListView` widget. You can use the options to customize. Or simply copy all the code of the widget and customize with your own code.

```dart
return Scaffold(
  appBar: AppBar(
    title: const Text('Chat Rooms'),
  ),
  body: const DefaultChatRoomListView(),
);
```

### Chat room create

You can show the `DefaultChatRoomEditDialog()` to create a chat room. You can also copy and modify the code of the widget to customize as needed.

You can also use `ChatService.instance.showChatRoomCreate()` to show the default Chat Room creation dialog.

```dart
IconButton(
  onPressed: () async {
    final ChatRoom? room = await ChatService.instance.showChatRoomCreate(context: context);
    if (!context.mounted) return;
    if (room == null) return;
    ChatService.instance.showChatRoom(context: context, room: room);
  },
  icon: const Icon(Icons.add),
),
```

## Easy-to-Use Convenient Widgets

### LabelField

A simple text field with label.

```dart
LabelField(
    label: "Email",
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
),
```

## Display User Profile Sticker - MyProfileSticker

The user profile sticker is a widget that displays the following elements:

- The photo of the logged-in user on the left side.
- A profile edit button on the right side.
- The user's name displayed at the top center.
- The user's status message displayed at the bottom center.

Design changes can be made using the Theme widget, and if necessary, you can copy and modify the source code for your own use.

![my_profile_sticker](https://github.com/thruthesky/fireship/blob/main/docs/assets/images/my_profile_sticker.jpg?raw=true)

The code below is an example to apply a theme (to change a design). The example uses Sliver but it will depend on your design. In this way, the design can be changed without modifying the source code.

```dart
SliverToBoxAdapter(
  child: Theme(
    data: Theme.of(context).copyWith(
      chipTheme: ChipThemeData(
        padding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        backgroundColor: context.onSurface.withAlpha(10),
        side: BorderSide(color: context.onSurface.withAlpha(20)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        selectedColor: context.primary,
        labelStyle:
            Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.onSurface,
                ),
      ),
    ),
    child: const MyProfileSticker(),
  ),
),
```

## User List - NewProfilePhotos

When a user changes their photo, its URL is copied to `/user-profile-photos/<uid>`. The `NewProfilePhotos` displays the user's photo on the screen based on this value.

![my_profile_sticker](https://github.com/thruthesky/fireship/blob/main/docs/assets/images/new_profile_photos.jpg?raw=true)

Example:

```dart
NewProfilePhotos()
```
