# 관리자

- 관리자 중에서는 고객 상담(앱내 문의)을 전담하는 채팅 상담사가 있어야 한다. 그러한 상담 관리자는 `admins/{uid: ['chat']}` 과 같이 `chat` 옵션을 추가해서 저장을 한다. 단 주의 할 것은 chat 옵션을 가진 관리자는 1명 이어야만 한다.



- 관리자인지 아닌지는 `AdminService.instance.isAdmin` 으로 확인을 할 수 있으며,

- DB 가 변경될 때 또는 사용자 UID 가 변경 될 때, StreamBuilder 로 실시간 업데이트를 하고자 하는 경우 아래와 같이 할 수 있다.

```dart
StreamBuilder(
  stream: AdminService.instance.isAdminStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox();
    }

    if (snapshot.data != true) return const SizedBox();

    return Text('You are an admin');
  }
);
```

