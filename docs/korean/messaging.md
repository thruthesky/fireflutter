# 푸시 알림


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



## FCM 과 token

Fireflutter uses FCM to send messages to devices.

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


