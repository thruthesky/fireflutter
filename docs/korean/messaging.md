# 푸시 알림

- 토픽을 사용하지 않고, 사용자 토큰 별로 메시지를 보낸다. 그래서 구독을 했는지 안했는지에 대한 정보를 DB 에 보관해야하는데, 각 기능별 문서를 참고하도록 한다.


## 푸시 알림 설치

- 먼저, 푸시 알림 전송을 담당하는 함수를 `Firebase Cloud Functions` 에 배포해야 합니다
  - `sendMessagesToChatRoomSubscribers`
  - `sendPushNotifications`
  - `sendMessagesToCategorySubscribers`

- 그리고 iOS 에서 푸시 알림 관련 설정을 해야 합니다. 참고로 Android 에서는 설정이 필요 없습니다.

- 그리고 앱에 푸시 알림 초기화 코드를 추가해야 합니다.

- 그리고 푸시 알림 토큰이 DB 에 잘 저장되는지 확인합니다.

- 그리고 푸시 메시지를 보내 봅니다.
  - 먼저, `파이어베이스 콘솔` 에서 보내 봅니다. 이것이 가장 쉽습니다. 공홈 참고 [Send a notification message](https://firebase.google.com/docs/cloud-messaging/flutter/first-message?_gl=1*13pdja2*_up*MQ..*_ga*NjAwOTEyNC4xNzExMjU4MDcx*_ga_CW55HF8NVT*MTcxMTI1ODA3MC4xLjAuMTcxMTI1ODA3MC4wLjAuMA..#send_a_test_notification_message)
  - 만약, 파이어베이스 콘솔에서 테스트 메시지를 보냇는데, 메시지가 수신되지 않으면, `send-a-message.spec.ts` 를 통해서 메시지를 보냅니다. 이렇게 하면 좀 더 상세한 에러 메시지를 확인 할 수 있습니다. 참고, [테스트 문서](./test.md)에서 FCM 테스트 항목을 참고해 보세요.



## 푸시 알림 데이터베이스 구조


- 토큰은 `/user-fcm-tokens/<token> { uid: [user uid], platform: [android or ios]}` 와 같이 저장된다.
  - 즉, 키가 토큰이며 값은 `uid` 와 `platform` 이다. 따라서 키를 기준으로 해당 토큰이 누구의 것인지 알 수 없으며, 특정 사용자의 토큰을 얻기 위해서는 `uid` 를 바탕으로 필터링을 해야한다.
  - 사용자 `uid` 는 필수 값이므로 로그인을 해야지만 token 을 저장한다.
  - 만약 로그인을 하지 않은 모든 사용자에게 푸시 알림을 전송하고 싶다면 파이어베이스 콘솔에서 메시지를 전송 할 수 있다.

- 토큰을 저장하는 코드는
  - `messaging.service.dart` 의 `_updateToken()` 와
  - `test.functions.ts` 의 `createTestUser()` 를 보면 된다.


- 푸시 알림 기록은 `/push-notification-logs/<id>` 에 기록된다.
  - `action` 에는 `post`, `comment`, `chat`, `like`, `profile` 등의 값이 들어 갈 수 있으며,
  - `targetId` 에는 새 글의 ID, 새 코멘트의 ID, 새 채팅 메시지의 ID, `like` 의 경우, 상대 유저의 uid, `profile` 의 경우, 상대 유저의 uid 가 저장된다. 그래서 어떤 이벤트의 어느 대상으로 인해서 푸시 알림이 전송되는지 알 수 있다.
  - `createdAt` 은 메시지 전송 시간
  - `tokens` 는 메시지가 전송된 토큰 목록이다.
  - 주의 할 것은 많은 사용자에게 푸시 알림을 하는 경우, DB 에 기록되는 데이터가 커져서 추가 비용이 발생할 수 있다. 그래서 가능한 꺼 놓도록 한다. `Config.ts` 의 `logPushNotificationLogs` 를 false 로 하면, 푸시 알림 기록을 하지 않는다.

  

## 초기화

- 개발을 할 때 인터넷 연결을 와이파이 접속으로 하는 경우, 앱이 시작하자 마자 MessageingService.instance.init() 을 호출하고 초기화를 하려고 하면 `FirebaseException :  [firebase_messaging/unknown] 인터넷 연결이 오프라인 상태입니다. }` 와 같은 에러를 만날 수 있다. 이 에러는 Android, Emulator, Simulator 에서는 잘 발생하지 않고, 실제 iPhone 장치에서 자주 발생한다. 혹시라도 이 문제가 실제 사용자가 쓸 때 발생할 수 있으므로, 아래와 같이 connectivity_plus 를 통해서 해결한다.

- 먼저, `connectivity_plus` 패키지를 프로젝트에 추가한다.

- 그리고 아래와 같이 초기화를 한다.

```dart

class _MyAppState extends State<PhiLovApp> {
  /// 인터넷 연결 Subscription
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  @override
  void initState() {
    super.initState();

    initFirstInternetConnection();
  }
  /// 인터넷 연결을 최초로 할 때, 1회만 MessagingService 를 초기화 하여, 푸시 토큰을 저장한다.
  /// 아래와 같이 하면, iPhone 인터넷이 연결되어야지만, 토큰을 가져온다는 확인을 사용자에게 보낸다.
  initFirstInternetConnection() {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResult) {
      dog('connectivityResult: $connectivityResult');

      /// 인터넷에 연결되었는가?
      if (connectivityResult.contains(ConnectivityResult.none) == false) {
        /// 그렇다면, 최초 1회 인터넷 연결만 확인하고 Subscription을 취소하여, 인터넷 순단에 대한 이벤트를 더 이상 받지 않는다.
        /// 즉, 한번만 실행한다.
        connectivitySubscription?.cancel();
        dog('initConnectivity: 인터넷 연결이 되어 있음. MessagingService 를 초기화하여 푸시 알림 서비스를 시작합니다.');
        MessagingService.instance.init(
          onBackgroundMessage: (RemoteMessage message) async {},
          onForegroundMessage: (RemoteMessage message) {},
          onMessageOpenedFromTerminated: (RemoteMessage message) {},
          onMessageOpenedFromBackground: (RemoteMessage message) {},
          onNotificationPermissionDenied: () {
            dog("onNotificationPermissionDenied()");
          },
          onNotificationPermissionNotDetermined: () {
            dog("onNotificationPermissionNotDetermined()");
          },
        );
      }
    });
  }
}
```


## 게시판 구독

## 코멘트 구독

- 나의 글 또는 코멘트에 새로운 코멘트가 작성되면 푸시 알림을 받을 수 있다.
- [사용자 설정 문서](./user_settings.md)에 보면, 나의 글 또는 코멘트에 새 코멘트가 작성되면 푸시 알림을 받기 위해서 어떻게 설정되어야 하는지 알 수 있다.
- 새 코멘트가 작성되면 클라우드 함수의 `sendMessagesToCommentSubscribers` 가 동작한다.



## 채팅방 구독


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

There are firebase cloud functions that work with Fireflutter for sending messages to subscribers on forum categories and chat rooms.

You will need to install `sendMessagesToCategorySubscribers` and `sendMessagesToChatRoomSubscribers` in `firebase/functions/src/messaging/functions.ts` to make it work.

The source code is under `firebase/functions` and the test code is under `firebase/functions/tests`.

## Unit testing

See `firebase/functions/tests` folder for unit testing on push notification. To run the unit test code, you need to set the environment variable - `GOOGLE_APPLICATION_CREDENTIAILS`

## 시스템트레이에서 메시지가 탭 되면 화면 열기

사용자가 시스템트레이에서 메시지를 탭하면, 채팅, 글, 사용자 프로필 등의 페이지를 열어야 한다.

사용자가 메시지를 탭하면 내부적으로 `parseData` 를 통해서 푸시 알림 데이터를 모델링한다.

푸시 알림 메시지가 탭 되면, 라우팅되는 화면은 각 앱 마다 다를 수 밖에 없다. 아래의 예제를 보고 적당하게 수정해서 사용하면 된다.

```dart
Future<void> _onMessageTapped(RemoteMessage message) async {
  dog("onMessageTapped trigged.");
  dog("onMessageTapped: ${message.data.toString()}");

  final data = MessagingService.instance.parseData(message.data);

  if (data is ChatMessagingModel) {
    ChatService.instance.showChatRoom(
      context: globalContext,
      roomId: data.roomId,
    );
    return;
  }

  if (data is PostMessagingModel) {
    Post? post =
        await Post.get(category: data.category, id: data.id);
    if (post == null) return;
    if (globalContext.mounted) {
      ForumService.instance.showPostViewScreen(
        globalContext,
        post: post,
      );
    }
    return;
  }

  if (data is UserMessagingModel) {
    UserService.instance.showPublicProfileScreen(
      context: globalContext,
      uid: data.uid,
    );
    return;
  }
}
```

## 사용자 프로필 보기 메시지

A 가 B 의 프로필을 보면, B 는 푸시 알림을 받을 수 있다. 즉, 누가 나의 프로필을 봤는지 알림을 받는 것이다.

사용자 프로필을 보는 경우, 푸시 알림은 클라이언트에서 처리하는데, user.service.dart 의 showPublicProfileScreen 에서 작업 처리한다.

프로필 보기를 할 때, 푸시 알림을 하는 조건은

- 앱 초기화를 할 때, `UserService.init()` 에서 프로필 보기를 할 때, 푸시 알림 설정을 하고
- 사용자 설정에서 `profileViewNotification` 에 false 가 아닌 값을 저장하면 푸시 알림을 한다. 즉, 이 값이 존재하지 않거나(null 이거나), true 인 경우에 푸시 알림을 한다.




## 사용자 프로필이 보여질 때, 푸시 알림 커스터마이징

`enablePushNotificationOnPublicProfileView` 옵션을 true 로 주면, A 의 공개 프로필이 B 에 의해서 보여질 때 이용해서 (즉, B 가 A 를 볼 때), 푸시 알림을 A 에게 보낼 수 있다. 하지만 기본적으로 푸시 알림 코드가 마음에 들지 않는다면, 직접 코딩을 통해서 푸시 알림 로직을 작성 할 수 있다.

예를 들면, A 는 영어를 쓰고, B 는 한글로 쓴다면, A 에게는 영어로 푸시 알림이 가야한다. 즉, B 의 핸드폰(또는 앱) 설정이 한글이라고 해서, 푸시 알림이 한글로 가면 안되는 것이다. 이와 같은 때에 푸시 알림 로직을 직접 코딩 할 수 있다.

먼저, `enablePushNotificationOnPublicProfileView` 를 false 로 지정해서, 기본 푸시 알림 로직이 실행되지 않도록 한다. 그리고, `pushNotificationOnPublicProfileView` 을 custom 함수로 만들고 그 안에서 직접 푸시 알림 로직을 수행하면 되는 것이다. 참고로, `pushNotificationOnPublicProfileView` 에 콜백 함수가 지정되면, `enablePushNotificationOnPublicProfileView` 는 무시된다.

아래의 예제는 B 가 A 프로필을 방문하면, A 의 언어 맞게 번역하여 푸시 알림을 보내는 예제이다. 직접 `MessagingService.instance.sendTo()` 함수를 호출하면 된다.

```dart
void initUserService() {
  UserService.instance.init(
    customize: UserCustomize(
      pushNotificationOnPublicProfileView: (User otherUser) async {

        /// 상대방의 언어 설정을 가져온다.
        final otherUserLanguageCode =
            await UserSetting.getField(otherUser.uid, Field.languageCode);

        String title;
        if (otherUserLanguageCode == 'my') {
          title = 'သင့်ပရိုဖိုင်ကို ဝင်ကြည့်ခဲ့သည်။';
        } else if (otherUserLanguageCode == 'ko') {
          title = '당신의 프로필을 방문했습니다.';
        } else if (otherUserLanguageCode == 'lo') {
          title = 'ທ່ານໄດ້ເຂົ້າໜ້າໂປຣໄຟລຂອງທ່ານ.';
        } else if (otherUserLanguageCode == 'vi') {
          title = 'Bạn đã ghé thăm hồ sơ của bạn.';
        } else if (otherUserLanguageCode == 'th') {
          title = 'คุณได้เยี่ยมชมโปรไฟล์ของคุณแล้ว.';
        } else {
          title = 'Someone visited your profile.';
        }

        String body;
        if (otherUserLanguageCode == 'my') {
          body = 'သင့်ပရိုဖိုင်ကို ဝင်ကြည့်ပါ။';
        } else if (otherUserLanguageCode == 'ko') {
          body = '#name님께서 회원님의 프로필을 방문했습니다.';
        } else if (otherUserLanguageCode == 'lo') {
          body = 'ທ່ານໄດ້ເຂົ້າໜ້າໂປຣໄຟລຂອງທ່ານ.';
        } else if (otherUserLanguageCode == 'vi') {
          body = 'Bạn đã ghé thăm hồ sơ của bạn.';
        } else if (otherUserLanguageCode == 'th') {
          body = 'คุณได้เยี่ยมชมโปรไฟล์ของคุณแล้ว.';
        } else {
          body = '#name visited your profile.';
        }
        await MessagingService.instance.sendTo(
          title: title,
          body: body.replaceAll('#name', my!.displayName),
          uid: otherUser.uid,
          image: user.photoUrl,
        );
      },
    ),
  );
}
```


