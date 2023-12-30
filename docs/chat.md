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


### 채팅방 목록


RTDB 의 특성상 채팅방을 목록 할 때,
- 나의 1:1 채팅방 목록 중 날짜순
- 나의 전체 채팅방 목록 중 날짜순
- 오픈챗 목록 중 날짜순
등으로 표시하기가 매우 힘들다.

그래서, isSingleChat: 에 음수의 시간을 지정해서, 나의 1:1 채팅방 목록에서 최근 채팅 채팅 목록으로 표시 할 수 있다.
이것은 isGroupChat 과 isOpenGroupChat 도 마찬가지이다.



그래서, 채팅방 목록 전체를 다 가져와서 한번에 표시한다. 즉, 나의 1:1 채팅방 목록을 할 때에는 나의 1:1 채팅방 목록 전체를 다 가져와서 날싸순으로 표시를 하는 것이다. 이것을 나의 전체 그룹 채팅, 그리고 모든 오픈 채팅과 동일하게 표시를 한다.
다만, 이렇게 하려면 개개인(사용자)의 채팅 방수가 너무 많으면 안된다. 전반적으로 1인당 500개 이하는 무난 할 것 같다. 2천개 이하도 괜찮을 것 같기도 하다. 다만 한 사용자의 방 수가 2천 개 이상 이면 좀 무리가 되지 않을까 싶다. 그래서 방수를 제한하는 것도 하나의 방법이겠다. 또한 오픈 챗의 개수가 2천개 이상 넘어가도 문제가 될 것 같다.



## 관리

- 기본 관리자 화면을 사용하면 된다. `AdminService.instance.showDashboard()` 를 호출하면 된다.

### 오픈 챗 목록

### 오픈 챗 메시지 데이터 삭제

