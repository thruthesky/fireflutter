# 채팅


## 디자인 컨셉

- 동시에 여러개의 채팅방을 열 수 있다.


## 로직



### 채팅방 생성

간단하게 채팅방을 생성하는 방법은 아래와 같다.


```dart
ChatModel chat = ChatModel(room: ChatRoomModel.fromRoomdId('all'))..join();
ChatMessageListView(chat: chat)
```


ChatModel 만드는 것 만으로 채팅방이 만들어지지 않는다. 그래서 join() 을 추가적으로 호출한다.

`join()` 을 호출하면, `/chat-rooms/all/users` 에 `{uid: true}` 가 생성된다.

그리고 `ChatMessageListView` 위젯을 화면에 표시하면, 내부적으로 `ChatMessageListView::initState() -> ChatModel::resetMyRoomNewMessage()` 에서 RTDB `chat-joins/all` 에 `{order: 0}` 을 저장한다.



### 채팅방 메시지 전송

```dart
// 사용자 로그인
await loginOrRegister(
    email: 'test$i@email.com',
    password: '12345a',
    photoUrl: 'https://picsum.photos/id/$i/300/300',
);
// 메시지 전송

```



## 관리

- 기본 관리자 화면을 사용하면 된다. `AdminService.instance.showDashboard()` 를 호출하면 된다.

### 오픈 챗 목록

### 오픈 챗 메시지 데이터 삭제

