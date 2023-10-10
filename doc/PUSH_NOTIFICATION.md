# Push notifications

Push notification tokens are saved under `/users/{uid}/fcm_tokens/{token} { uid: ..., device_type: ..., fcm_token: ... }`. If the user didn't sign in, the token will not be saved.

The admin can send push notification to all the devices, or specific type/os through cloud function by creating a push notification document.

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

Below shows how to search a user and send a push message to the user

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

## Push notification settings

Each of push notification option is saved as a single document under `/users/{uid}/user_settings/{settingDocumentId}` with fields consist of {action: comment-create, category: qna, uid: userUid}. And it is protected by the security rules. Only the user can access this document. The option is saved in a separate document for the search. To give convinience on search and getting tokens of users who subscribe to the service.

- One thing to note, the field name must be unique due to the limit of 200 Firestore query index. So, a field name should not be like `{comment-create.qna: true}`. It should be like separated as `action` and `category`.
- But `subscriptionDocumentId` can be a unique document id like `comment-create.qna`, `post-create.discussion`.
  - Be careful not to save any document which has `action` and `category` on other setting document aside from the subscription settings document. It would work if the `action` field does not contain `post-create` or `comment-create` thought.
- So, the subscription document would be `/users/<uid>/user_settings/comment-create.qna {action: comment-create, category: qna}`.
- if `{action: comment-create, category: qna}` is set, there will be a new message on a new comment in qna category.
- if `{action: post-create, category: discussion}` is set, then there will be a messgae on new post on discussion category.

- User options for receiving all the comments under the user's posts or comments is saved like below
  - `/users/<uid>/user_settings/settings {notify-new-comment-under-my-posts-and-comments: true}`

The format of the document is in

```json
{
  "id": "The document ID",
  "uid": "the login user's uid",
  "action": "post.create or comment.create or chat.disable",
  "categoryId": "for post only",
  "roomId": "for chat only"
}
```

For chat room, when a user enters into a chat room, the push notification is enabled by default unless the user turn off the push notification manually. When the user turns off the push notification, `chat.disable` action will be saved in the setting document.

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

## Customizing source

You can limit the uploaded sources. You can choose camera, gallery, or files like below.

```dart
ChatService.instance.init(
  uploadFromCamera: true,
  uploadFromGallery: true,
  uploadFromFile: false,
);
PostService.instance.init(
  uploadFromCamera: false,
  uploadFromGallery: true,
  uploadFromFile: false,
);
CommentService.instance.init(
  uploadFromCamera: true,
  uploadFromGallery: false,
  uploadFromFile: false,
);
```