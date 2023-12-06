# Push notifications

## Overview

When there are any activities that the user should be informed, the fireflutter can send push notifications to the user on the phone.

Flutterflow provides sending push messages with tokens. You can programmtically choose which tokens to send messages with.

- You may send a push message to all users
- Or just send a push message to specific user group like android, ios

You can design the app to

- send a push message to the user when a comment is created under his post or comment.
- send a message to the user when there is a post under the forum category that he subscribed.
- send a push message to the user when there is a new chat message in the chat room that he subscribed. (default, subscribe all the chat room)

You can also set the Android phone to display with head-up display.

## Strcuture

Push notification tokens are saved under `/users/{uid}/fcm_tokens/{token} { uid: ..., device_type: ..., fcm_token: ... }`.
If the user didn't sign in, the token will not be saved. What if you want to send push notifications to the users who didn't sign in? You may do so using Firebase console.

The `device_type` may be `ios` or `android`.

The admin can send push notification to all the devices, or specific type/os through cloud function by creating a push notification document.

## Initialization

- For iOS, you need to setup the `Firebase Cloud Messaging` described in [the office site](https://firebase.google.com/docs/cloud-messaging/flutter/client).

- Then, copy the code below into a place where it can be run on app boots. It would be good in `initState() { ... }` of the first widget of the app.

```dart
/// No push notification on web
if (kIsWeb) {
  return;
}

/// Push notification service init
MessagingService.instance.init(
  /// This method will be called, when app is in background or terminated.
  ///
  /// while the app is close and notification arrive you can use this to do small work
  /// example are changing the badge count or informing backend.
  onBackgroundMessage: (RemoteMessage message) async {
    dog('onBackgroundMessage: ${message.notification!.body!}');
  },

  /// This method will be called, when app is in foreground.
  onForegroundMessage: (RemoteMessage message) {
    dog('onForegroundMessage: ${message.notification!.body!}');
    toast(title: 'Push messag', message: message.notification!.body!);
  },

  /// This will triggered when the notification on tray was tap while the app is closed
  /// if you change screen right after the app is open it display only white screen.
  onMessageOpenedFromTerminated: (message) {
    dog('onMessageOpenedFromTerminated: ${message.notification!.body!}');
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      onMessageTapped(message);
    });
  },

  /// This will triggered when the notification on tray was tapped while the app is in background(The app is open but is in background status).
  onMessageOpenedFromBackground: (message) {
    dog('onMessageOpenedFromBackground: ${message.notification!.body!}');
    onMessageTapped(message);
  },

  ///
  onNotificationPermissionDenied: () {
    toast(
      title: 'Permission Denied',
      message: 'Please allow notification permission to receive push notifications.',
    );
  },
  onNotificationPermissionNotDetermined: () {
    toast(
      title: 'Permission Not Determined',
      message: 'Please allow notification permission to receive push notifications.',
    );
  },
);
```

- If everything is setup properly, the push token will be saved under `/users/<uid>/fcm_tokens/...`

- For the `Head-up display` in Android, Setting the importance to `NotificationManager.IMPORTANCE_HIGH` will shows the notification everywhere, makes noise and peeks. May use full screen intents.

## Push notification settings

- All user setting's documents including push notification setting document is saved under `/user/<uid>/user_settings` collection. We call it `user_settings` collection.
  - See the settings for more information.

Each of push notification option is saved as a single document under `user_settings` collection with fields consist of `action`, `categoryId`, `uid`. For instance, `{action: commentCreate, categoryId: qna, uid: userUid}`.

- Security rules,

  - Login user can only update their own `user_settings`
  - All users are allow to read other `user_settings`. In some cases we send push notification via `client device` and we need to filter those who dont want to receive push notification.

  ```ts
      match /user_settings/{docId} {
        allow read:  if true;
        allow write: if (request.auth.uid == userDocumentId);
      }
  ```

- Be careful not to save a document under `user_settings` collection that has `action` and `categoryId` if it's not for push notification settings.

- This is an example of a push notification subscription document - `/users/<my-uid>/user_settings/<document-id> {action: commentCreate, categoryId: qna}`.

- By default, cloud function event like `commentCreate`, `chatCreate`, `userCreate`, `reportCreate` will send push message automatically unless the user turn them off by adding specific `user_settings`. [Check send push notification with action](#send-push-notification-with-action)

- The format of the document is in

```json
{
  "id": "The document ID",
  "uid": "the login user's uid",
  "action": "postCreate or commentCreate or chatDisable",
  "categoryId": "for post only",
  "roomId": "for chat only"
}
```

## hierarchy of sending priority

- action >> topic >> tokens >> uids
- if action is not null, topic, tokens, uids will be ignored
- if action is null and topic is not null, then tokens and uids will be ignored
- if action and topic is null, and tokens is not null then uids will be ignored
- if action, topic, and tokens are null, then uids will be used

## 4 Different way to send push notification

Sending push message using `tokens`, `uids`, `topic` will directly send the push notification to users.

For app specific application like `forum`, using `user_settings` to on and off push message. [Check the Send push notification using action and categoryId](#sending-push-notification-with-action-and-categoryid).

### Send push notification with `tokens`

Below shows how to search a user and send a push message to the user using tokens

```dart
AdminService.instance.showUserSearchDialog(context, onTap: (user) async {
  final tokens = await Token.gets(uid: user.uid);
  MessagingService.instance.queue(
    title: 'message title',
    body: 'message body',
    tokens: tokens.map((e) => e.fcmToken).toList(),
  );
});
```

### Send push notification with `uids`

Sending push notification using user uid

- `uids` accept `List<String>`

```dart
AdminService.instance.showUserSearchDialog(context, onTap: (user) async {
  MessagingService.instance.queue(
    title: 'message title',
    body: 'message body',
    uids: [user.uid],
  );
});
```

### Send push notification with `topic`

Sending push notification using `topic`

By default `MessagingService.instance.init()` will try to subscribe the device to the following topics

- `allUsers`
- platform specific topic like
  - `iosUsers`
  - `androidUsers`
  - `webUsers`
  - `${platformName()}Users` - other platform name will also included

```dart
  MessagingService.instance.queue(
    title: 'message title',
    body: 'message body',
    topic: 'allUsers',
  );
```

### Send push notification with `action`

App specific event like `commentCreate`, `chatCreate`, `userCreate`, `reportCreate` will send push message automatically.

#### `commentCreate`

You may need to create an index for commentCreate Push Notification.

> action Ascending, categoryId Ascending, uid Ascending

Cloud function `messagingOnCommentCreate` event will trigger when comment is created

```ts
 exports.messagingOnCommentCreate = onDocumentCreated(
   "comments/{commentId}",
   async ( ... ):
   ....
 );
```

Since `commentCreate` by default will send push message to its ancestors and post author you can disable this by adding the setting below

- `/users/<uid>/user_settings/settings {action: disableNotifyNewCommentsUnderMyPostsAndComments}`

If a push notification is created with something like `{action: commentCreate, categoryId: qna, id: commentId}`

- This will send push message to ancestors comment and post author, But if the ancestor has`/users/<my-uid>/user_settings/<document-id> {action: disableNotifyNewCommentsUnderMyPostsAndComments}` then they will be remove from list
- This will also send push message to users who has `/users/<my-uid>/user_settings/<document-id> {action: 'commentCreate', categoryId: 'qna'}`
- It is possible to get push notification if you disable getting push notifcation from ancestor but you enable getting push message when a comment is created to a forum with `categoryId`
- It will remove duplicate uid so you will only get one push message for this event

  - It will get the Post author with Post.get(data.postId),
  - It will get all ancestor uids
  - It will filter the ancestor uids and post author if a document in `user_settings` has
    - `{action: disableNotifyNewCommentsUnderMyPostsAndComments}`
  - Since `categoryId` exist from post, it will also get uids if a document in `user_settings` has
    - `{action: 'commentCreate', categoryId: '${post.categoryId}'}`
  - Combine the filtered ancestor uids and uids who subscribe to `commentCreate` under a specific `categoryId`
  - It will send push message to combined uids

`commentCreate` payload

```ts
  const data: SendMessage = {
    id: event.data?.id,
    postId: comment.postId,
    action: EventName.commentCreate,
    type: EventType.post,
    senderUid: comment.uid,
    title: post.deleted == true ? "Deleted post..." : post.title ?? "Comment on post...";
  };
```

#### `chatCreate`

Cloud function `messagingOnChatMessageCreate` event will trigger when chat message is created.

```ts
  exports.messagingOnChatMessageCreate = onDocumentCreated(
    "chats/{chatId}/messages/{messageId}",
    async ( ... ):
    ....
  );
```

For chat room, when a user enters into a chat room, the push notification is enabled by default unless the user turn off the push notification manually. When the user turns off the push notification, `{action: chatDisabled, roomId: roomId}` action and roomId will be saved in the setting document.

- It will filter the uids if a document in `user_settings` has

- `{action: 'chatDisabled', roomId: 'data.roomId'}`

- It will send push message to remaining uids

`chatCreate` payload

```ts
const messageData: SendMessage = {
  type: EventType.chat,
  action: EventName.chatCreate,
  title: `${user?.display_name ?? user?.name ?? ""} send you a message.`,
  body: data.text,
  uids: await Chat.getOtherUserUidsFromChatMessageDocument(data),
  id: data.roomId,
  senderUid: data.uid,
};
```

#### `userCreate`

Cloud function `messagingOnUserCreate` event will trigger when new user is created.

```ts
  exports.messagingOnUserCreate = onDocumentCreated(
    "users/{userUid}",
    async ( ... ):
    ....
  );
```

`userCreate`

When a new user is registered it will send push notification to admin

- It will get users uid with `isAdmin` set to `true`
- It will remove admin with `/users/<my-uid>/user_settings/<document-id> {action: 'userCreate', categoryId: 'notifyOnNewUser'}`
- Send push message to remaining admin

`userCreate` payload

```ts
const data: SendMessage = {
  title: "New Registration",
  content: "New User " + event.data?.id,
  id: event.data?.id,
  action: EventName.userCreate,
  type: EventType.user,
  senderUid: event.data?.id,
};
```

#### `reportCreate`

Cloud function `messagingOnReportCreate` event will trigger when new user is created.

```ts
  exports.messagingOnReportCreate = onDocumentCreated(
    "reports/{reportId}",
    async ( ... ):
    ....
  );
```

`reportCreate`

When a user create a report, it will send push message to admin

- It will get users uid with `isAdmin` set to `true`
- It will remove admin with `/users/<my-uid>/user_settings/<document-id> {action: 'reportCreate', categoryId: 'notifyOnNewReport'}`

`reportCreate` payload

```ts
const data: SendMessage = {
  title: "Report: " + report.type,
  body: report.reason,
  id: event.data?.id,
  action: EventName.reportCreate,
  type: EventType.report,
  senderUid: report.uid,
};
```

### Sending push notification with `action` and `categoryId`

For forum we can turn on and off notification button for user to subscribe or unsubscribe to certain `categoryId` then we can use `action` and `categoryId`

By default when we create a post the cloud function will invoke the `messagingOnPostCreate`

```ts
  exports.messagingOnPostCreate = onDocumentCreated(
    "posts/{postId}",
    async ( ... ):
    ....
  );
```

If a post is created under categoryId `discussion`

- This will get all users who has document like `/users/<my-uid>/user_settings/<document-id>{action:'postCreate', 'categoryId': 'discussion'}`
- And it send push message to those user who has the setting above

#### You can customize push message via `action` and `categoryId`

- To send push message to user who subscribe to `customAction` and `customCategory`
- You can create a document in `user_settings` like
  - `{action: 'customAction', 'categoryId': 'customCategoryId'}`
- You can then use the `MessagingService.instance.queue` like below to send to all user who has settings like above

```ts
 MessagingService.instance.queue(
   title: 'message title',
   body: 'message body',
   action: 'customAction',
   categoryId: 'customCategoryId'
 );
```

### Push notifcation sound

Android Setup

Sound file must exist on `android/app/src/main/res/raw` directory

Android below 8.0 (API < 26) providing the sound `filename` on the push notification payload will work already.

android payload

```ts
    android: {
      notification: {
        sound: "sound_file_name",
      },
    },
```

Android 8.0 and above(API >= 26) need to setup a channel and provide the `channel_id` on the payload

```ts
    android: {
      notification: {
        channel_id: "CHANNEL_ID",
      },
    },
```

Simply provide both to support old and new API

```ts
    android: {
      notification: {
        channel_id: "CHANNEL_ID",
        sound: "sound_file_name",
      },
    },
```

main.dart

```dart
  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid) initNotificationChannel();
  }

  initNotificationChannel() async {
    const MethodChannel channel =
        MethodChannel('com.fireflutter.example/push_notification');
    Map<String, String> channelMap1 = {
      "id": "DEFAULT_CHANNEL",
      "name": "Default push notifications",
      "description": "Default push notifications channel settings",
      "sound": "default"
    };
    try {
      final res1 =
          await channel.invokeMethod('createNotificationChannel', channelMap1);
    } on PlatformException catch (e) {
      log(e.toString());
    }
  }
```

MainActivity.kt

```kotlin
import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.net.Uri;
import android.media.AudioAttributes;
import android.content.ContentResolver;

class MainActivity: FlutterActivity() {
    // Note: this should be the same as the string we will pass on MethodChannel
    // when we init the channel create on main.dart
    private val CHANNEL = "com.fireflutter.example/push_notification"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        // Note: this method is invoked on the main thread.
            call, result ->
            if (call.method == "createNotificationChannel"){
                val argData = call.arguments as java.util.HashMap<String, String>
                val completed = createNotificationChannel(argData)
                if (completed == true){
                    result.success(completed)
                }
                else{
                    result.error("Error Code", "Error Message", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
    private fun createNotificationChannel(mapData: HashMap<String,String>): Boolean {
        val completed: Boolean
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
            // Create the NotificationChannel
            val id = mapData["id"]
            val name = mapData["name"]
            val descriptionText = mapData["description"]
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel(id, name, importance)
            mChannel.description = descriptionText
            if (mapData["sound"] != null) {
                val sound = mapData["sound"]
                val soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://"+ getApplicationContext().getPackageName() + "/raw/" + sound);
                val att = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                .build();

                mChannel.setSound(soundUri, att)
            }
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
            completed = true
        }
        else{
            completed = false
        }
        return completed
    }
}
```

Setting the importance to `NotificationManager.IMPORTANCE_HIGH` will shows the notification everywhere, makes noise and peeks. May use full screen intents.

iOS Setup

Sound file must be add on the XCode main bundle

iOS Payload

```ts
    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
    },
```

## Send push notification to custom topic

- @TODO remove topic subscription

Initialize custom topic by providing a list of `CustomizeMessagingTopic` to `customizeTopic` on init().
Subscribe to topic base on your business logic and base from the customizeTopic list.
Under the AdminMessagingScreen, you will see the list of topic you initialized and you can send push notification to the topic.

```dart
  initMessagingService() {
    MessagingService.instance.init(
      customizeTopic: [
        CustomizeMessagingTopic(
          topic: 'allUsers',
          title: 'All',
        ),
        CustomizeMessagingTopic(
          topic: 'coach',
          title: 'Coachs',
        ),
        CustomizeMessagingTopic(
          topic: 'player',
          title: 'Players',
        ),
      ],
    )
  }
```

Subscribe to topic according to business logic

```dart
  initUserService() {
    UserService.instance.init(
      onCreate: (User user) async {
        MessagingService.instance.subscribeToCustomTopic('allUsers');
      },
      onUpdate: (User user) async {
        /// unsubscribe to all topics except the current user type.
        for (final type in ['coach', 'player']) {
          if (type != user.type) {
            MessagingService.instance.unsubscribeToCustomTopic(type);
          }
        }
        /// subscribe to the current user type.
        if (user.type.isNotEmpty) {
          MessagingService.instance.subscribeToCustomTopic(user.type);
        }
      },
    );
```

## Testing

You can test the push notification routing.

```dart
/// TEST CODE
Timer(const Duration(seconds: 1), () {
  routeFromMessage({
    'badge': '',
    'id': 'so7HI41U2QfQRu86B7EF',
    'roomId': '',
    'type': 'post',
    'senderUid': '2F49sxIA3JbQPp38HHUTPR2XZ062' 'xxx',
    'action': '',
  });
});

  routeFromMessage(Map<String, dynamic> messageData) async {
    final data = MessagingService.instance.parseMessageData(messageData);
    dog(data.toString());

    /**
     * return if the the sender is also the current loggedIn user.
     */
    if (myUid == data.senderUid) {
      return;
    }

    /**
       * If the type is user then move it to public use profile.
       */
    if (data.type == NotificationType.user) {
      /// if the action is userCreate then move it to public profile.
      if (data.action == 'userCreate') {
        // return UserService.instance.showPublicProfileScreen(context: context, uid: data.id);
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (c) => const AdminUserListView(
              createdAtDescending: true,
            ),
          ),
        );
      }
      // this should work but it needs tests/review.
      // context.push does not work
      // return GoRouter.of(context).push(MyViewersScreen.routeName);
    }

    /**
       * If the type is post then move it to a specific post.
       */
    if (data.type == NotificationType.post) {
      /// else show the viewer screen
      return PostService.instance.showPostViewScreen(
        context: context,
        postId: data.id,
      );
    }

    if (data.type == NotificationType.report) {
      return Navigator.of(context).push(MaterialPageRoute(builder: (c) => const AdminReportListScreen()));
    }

    /**
     * If the type is chat then move it to chat room.
     */
    if (data.type == NotificationType.chat) {
      // ignore: use_build_context_synchronously
      return ChatService.instance.showChatRoom(
        context: context,
        room: await Room.get(
          data.id,
        ),
      );
    }
  }
```
