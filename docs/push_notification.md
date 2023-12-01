# Push notifications


## Overview

Push notification tokens are saved under `/users/{uid}/fcm_tokens/{token} { uid: ..., device_type: ..., fcm_token: ... }`. If the user didn't sign in, the token will not be saved.

The admin can send push notification to all the devices, or specific type/os through cloud function by creating a push notification document.


## Initialization

- For iOS, you need to setup the `Firebase Cloud Messaging` described in [the office site](https://firebase.google.com/docs/cloud-messaging/flutter/client).


- Then, copy the code below into a place where it can be run on app boots. It would be good in `initState() { ... }` of the first widget of the app.


```dart
    // init here
    MessagingService.instance.init(
      // while the app is close and notification arrive you can use this to do small work
      // example are changing the badge count or informing backend.
      onBackgroundMessage: onTerminatedMessage,

      ///
      onForegroundMessage: (RemoteMessage message) {
        onForegroundMessage(message);
      },
      onMessageOpenedFromTerminated: (message) {
        // this will triggered when the notification on tray was tap while the app is closed
        // if you change screen right after the app is open it display only white screen.
        WidgetsBinding.instance.addPostFrameCallback((duration) {
          onTapMessage(message);
        });
      },
      // this will triggered when the notification on tray was tap while the app is open but in background state.
      onMessageOpenedFromBackground: (message) {
        onTapMessage(message);
      },
      onNotificationPermissionDenied: () {
        // print('onNotificationPermissionDenied()');
      },
      onNotificationPermissionNotDetermined: () {
        // print('onNotificationPermissionNotDetermined()');
      },
    );
```

- For the `Head-up display` in Android, you need to have some extra setup.


## Push notification settings

- All user setting's documents including push notification setting document is saved under `/user/<uid>/user_settings` collection. We call it `user_settings` collection.
  - See the settings for more information.

Each of push notification option is saved as a single document under `user_settings` collection with fields consist of `action`, `categoryId`, `uid`. For instance, `{action: commentCreate, category: qna, uid: userUid}`.

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

- This is an example of a push notification subscription document - `/users/<my-uid>/user_settings/<document-id> {action: commentCreate, category: qna}`.

- By default, cloud function event like `commentCreate`, `chatCreate`, `userCreate`, `reportCreate` will send push message automatically unless the user turn them off by adding specific `user_settings`. [Check send push notification with action](#send-push-notification-with-action)


- Since `commentCreate` by default will send push message to its ancestors and post owner you can disable this by adding the setting below
  - `/users/<uid>/user_settings/settings {action: disableNotifyNewCommentsUnderMyPostsAndComments}`


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
    - `${platformName()}Users` - other platformname will also included

```dart
  MessagingService.instance.queue(
    title: 'message title',
    body: 'message body',
    topic: 'allUsers',
  );
```

### Send push notification with `action`

App specific event like `commentCreate`, `chatCreate`, `userCreate`, `reportCreate`

#### `commentCreate`

Cloud function auto generated event onDocumentCreated when comment is created

If a push notification is created with something like `{action: commentCreate, categoryId: qna, id: commentId}`

- This will send push message to ancestors comment and post author, But if the ancestor has`/users/<my-uid>/user_settings/<document-id> {action: disableNotifyNewCommentsUnderMyPostsAndComments}` then they will be remove from list
- This will also send push message to users who has `/users/<my-uid>/user_settings/<document-id> {action: 'commentCreate', categoryId: 'qna'}`
- It is possible to get push notification if you disable getting push notifcation from ancestor but you enable getting push message when a comment is created to a forum with `categoryId`
- You will only get one notification for this event

```ts 
  exports.messagingOnCommentCreate = onDocumentCreated(
    "comments/{commentId}",
    async ( ... ): 
    ....
  );
```

  - It will get the Post author with Post.get(data.postId), 
  - It will get all ancestor uids
  - It will filter the ancestor uids and post author if a document  in `user_settings` has
    - `{action: disableNotifyNewCommentsUnderMyPostsAndComments}`
  - Since `categoryId` exist from post, it will also get uids if a document in `user_settings` has
    - `{action: 'commentCreate', categoryId: '${post.categoryId}'}`
  - Combine the filtered ancestor uids and uids who subscribe to `commentCreate` under a specific `categoryId`
  - It will send push message to combined uids

  - `commentCreate` payload

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
Cloud function auto generated event onDocumentCreated when chat message is created

- For chat room, when a user enters into a chat room, the push notification is enabled by default unless the user turn off the push notification manually. When the user turns off the push notification, `{action: chatDisabled, roomId: roomId}` action and roomId will be saved in the setting document.

```ts 
  exports.messagingOnChatMessageCreate = onDocumentCreated(
    "chats/{chatId}/messages/{messageId}",
    async ( ... ): 
    ....
  );
```

  - It will filter the uids if a document in `user_settings` has
   - `{action: 'chatDisabled', roomId: 'data.roomId'}`
  - It will send push message to remaining uids
  - `chatCreate` payload

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

#### `userCreate`, `reportCreate`
Cloud function auto generated event onDocumentCreated for sending push notification to admin

`userCreate`

```ts 
  exports.messagingOnUserCreate = onDocumentCreated(
    "users/{userUid}",
    async ( ... ): 
    ....
  );
```

  - It will get users uid with `isAdmin` set to `true`
  - It will filter the uids and remove uid if a document in `user_settings` has
    - `{action: 'userCreate', categoryId: 'notifyOnNewUser'}`
  - `userCreate` payload

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

`reportCreate`

```ts 
  exports.messagingOnReportCreate = onDocumentCreated(
    "reports/{reportId}",
    async ( ... ): 
    ....
  );
```
  - It will get users uid with `isAdmin` set to `true`
  - It will filter the uids if a document in `user_settings` has
    - `{action: 'userCreate', categoryId: 'notifyOnNewUser'}`
  - `reportCreate` payload

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

Like in forum we want to have a on and off notification button for user to subscribe or unsubscribe to certain categoryId then we can use `action` and `categoryId`

- If `{action: post-create, category: discussion}` is set, then there will be a messgae on new post on discussion category.

By default when we create a post the cloud function invoke the 

```ts 
  exports.messagingOnPostCreate = onDocumentCreated(
    "posts/{postId}",
    async ( ... ): 
    ....
  );
```

  - then it will get all user who has document in `user_settings` with
    - `{action:'postCreate', 'categoryId': '${post.categoryId}'}`
  - And it send to those user who has the setting above


 
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


