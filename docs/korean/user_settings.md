# 사용자 설정

- `user-settings/<uid>` 에 사용자 설정이 저장된다.

- `enablePushNotificationOnProfileView` 에 true 를 저장하면, 누가 나의 프로필을 보면 나에게 푸시 알림이 도착한다.
  단, `UserService.instance.init(enablePushNotificationOnProfileView: true)` 와 같이 설정을 해야지만, 푸시 알림이 동작한다.
