# 관리자

## 개요

- 관리자 기능은 누가 관리자인지 확인을 하거나, 관리자에게 채팅을 하거나 등에서 사용 할 수 있다.

- 관리자 지정하기
  - 상담 관리자는 `admins/{uid: ['chat']}` 과 같이 `chat` 옵션을 주면 된다.

## 초기화

- `AdminService.instance.init()` 을 호출하면 관리자 목록을 RTDB 서버에서 가져와 관리(실시간 업데이트)를 한다.
  - 즉, `AdminService.instance.init()` 을 호출하지 않으면, 관리자 정보가 앱으로 다운로드 되지 않고, 관리자 기능이 올바로 동작하지 않을 수 있다.
  - 관리자 기능을 앱에서 사용하는 것은 옵션이지만, 사용을 해서, 관리 기능을 추가 해 주는 거이 좋다. 예를 들면, 관리자에게 채팅을 하기 위해서는 관리자 기능을 사용해야 한다.


## 관리자 인지 확인하기

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

## 관리자와 채팅하기

- 참고로, 관리자와 채팅을 하면, 자동으로 푸시 알림 메시지가 관리자에게 전달된다.

- `AdminService.instance.chatAdminUid` 에 채팅을 전담하는 관리자 UID 가 들어가 있다. 그래서 관리자와 채팅을 하기 위해서는 아래와 같이 하면 된다.

```dart
final room = ChatRoom.fromUid(AdminService.instance.chatAdminUid!);
ChatService.instance.showChatRoomScreen(roomId: roomId);
```

- 관리자과 대화창(1:1 채팅방)을 열지 않고, 곧바로 채팅 메시지를 보내기 위해서는 아래와 같이 하면 된다.

```dart
ChatModel chat = ChatModel(
  room: ChatRoom.fromUid(AdminService.instance.chatAdminUid!),
);
await chat.room.join();
await chat.room.reload();

chat.sendMessage(
  text: text,
  force: true,
);
```

- 관리자 중에서는 고객 상담(앱내 문의)을 전담하는 채팅 상담사가 있어야 한다. 그러한 상담 관리자는 `admins/{uid: ['chat']}` 과 같이 `chat` 옵션을 추가해서 저장을 한다. 단 주의 할 것은 chat 옵션을 가진 관리자는 1명 이어야만 한다.
  - 참고로, Firebase console 에서 처음 admins 데이터를 생성 할 때, Realtime Database 에서 `+` 버튼을 클릭하고 키는 `admins`으로 하고 값은 `{"FjCrteoXHgdYi6MjRp09d51F71H3": "chat"}` 로 하고, Type 은 `auto` 로 하면 된다.
  




## 관리자 화면



- `AdminService.instance.showDashboard()` 를 호출하면 FireFlutter 에서 제공하는 기본 관리자 화면이 나온다.


