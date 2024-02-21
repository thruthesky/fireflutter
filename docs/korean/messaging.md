# 푸시 알림



## FCM 과 token

Fireship uses FCM to send messages to devices.

The tokens are saved under `/user-fcm-tokens/<token> { uid: [user uid], platform: [android or ios]}`. So, if you want to get the tokens of a user, you must get the tokens by searching the uid.



## 구독

토픽을 사용하지 않고, 사용자 토큰 별로 메시지를 보낸다. 그래서 구독을 했는지 안했는지에 대한 정보를 DB 에 보관해야하는데, 각 기능별 문서를 참고하도록 한다.
참고, 게시판 구독
참고, 채팅방 구독



## Sending messages to user

One user may use multiple devices and one device may have multiple tokens. So, if the app sends a message to A, the app must query to get the tokens of A in `/user-fcm-tokens`

The code below shows how send a message to multiple users.

```dart
final List<String> uids = some.users;

//sending notification to the list of uids
await MessagingService.instance.sendTo(
  uids: uids,
  title: '... message title ...',
  body: '... message body ...',
  image: url,
);
```

To use this method, The firebase cloud function named `sendPushNotifications` in `firebase/functions/src/messaging/functions.ts` must be installed. See installation on how to install firebsae functions.


## Sending messages for forum category subscription and chat room subscription


There are firebase cloud functions that work with fireship for sending messages to subscribers on forum categories and chat rooms.

You will need to install `sendMessagesToCategorySubscribers` and `sendMessagesToChatRoomSubscribers` in `firebase/functions/src/messaging/functions.ts` to make it work.

The source code is under `firebase/functions` and the test code is under `firebase/functions/tests`.



## Unit testing

See `firebase/functions/tests` folder for unit testing on push notification. To run the unit test code, you need to set the environment variable - `GOOGLE_APPLICATION_CREDENTIAILS`