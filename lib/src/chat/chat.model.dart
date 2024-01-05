import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireship/fireship.dart';
import 'package:fireship/ref.dart';

/// ChatModel
///
/// 이 모델은 채팅방의 데이터 모델이 아니라, 로직을 담고 있는 로직 모델이다.
/// This model is not a data model for the chat room but a logic model containing the logic.
///
/// ChatService 에 모든 것을 다 집어 넣으면, 각 채팅 방마다 관리가 어렵다. 그래서 동시에 두개의 채팅방을 열 수 없다.
/// If everything is put into ChatService, it becomes challenging to manage each chat room.
/// Therefore, it is not possible to open two chat rooms simultaneously.
class ChatModel {
  /// Set the current room.
  ChatRoomModel room;
  FirebaseDatabase get rtdb => FirebaseDatabase.instance;
  DatabaseReference get roomsRef => rtdb.ref().child('chat-rooms');
  DatabaseReference get messageseRef => rtdb.ref().child('chat-messages');
  DatabaseReference roomRef(String roomId) => roomsRef.child(roomId);
  DatabaseReference messageRef({required String roomId}) => rtdb.ref().child('chat-messages').child(roomId);

  /// [roomUserRef] is the reference to the users node under the group chat room. Ex) /chat-rooms/{roomId}/users/{my-uid}
  DatabaseReference roomUserRef(String roomId, String uid) => rtdb.ref().child('chat-rooms/$roomId/users/$uid');

  DatabaseReference get joinsRef => rtdb.ref().child('chat-joins');
  DatabaseReference joinRef(String myUid, String roomId) => joinsRef.child(myUid).child(roomId);

  // This is used to update the last message in the chat room list per user in /chat-joins
  String joinPath(String roomId, String uid) => '/chat-joins/$uid/$roomId';

  get service => ChatService.instance;

  ChatModel({
    required this.room,
  });

  resetRoom({required ChatRoomModel room}) {
    this.room = room;
  }

  /// 채팅 메시지 전송
  ///
  ///
  Future<void> sendMessage({
    String? text,
    String? url,
  }) async {
    if ((url == null || url.isEmpty) && (text == null || text.isEmpty)) return;

    /// TODO 관리자 모드에서 특정 사용자에게 disabled 할 수 있도록 한다.
    if (UserService.instance.user?.isDisabled == true) {
      throw ErrorCode(Code.disabled);
    }

    if (room.joined == false) {
      throw ErrorCode(Code.notJoined);
    }

    ///
    service.roomMessageOrder[room.id] = (service.roomMessageOrder[room.id] ?? 0) - 1;

    /// 참고, 실제 메시지를 보내기 전에, 채팅방 자체를 먼저 업데이트 해 버린다.
    ///
    /// 상황 발생, A 가 B 가 모두 채팅방에 들어가 있는 상태에서
    /// A 가 B 에게 채팅 메시지를 보내면, 그 즉시 B 의 채팅방 목록이 업데이트되고,
    /// B 의 채팅방의 newMessage 가 0 으로 된다.
    /// 그리고, 나서 updateJoin() 을 하면, B 의 채팅 메시지가 1이 되는 것이다.
    /// 즉, 0이 되어야하는데 1이 되는 상황이 발생한다. 그래서, updateJoin() 이 먼저 호출되어야 한다.
    Map<String, dynamic> multiUpdateData = _getMultiUpdateForChatJoinLastMessage(text: text, url: url);

    /// Save chat message under `/chat-messages`.
    // 저장할 채팅 데이터
    final chatMessageData = {
      'uid': myUid,
      if (text != null) 'text': text,
      if (url != null) 'url': url,
      'order': service.roomMessageOrder[room.id],
      'createdAt': ServerValue.timestamp,
    };
    // 저장 할 경로
    final chatMessageRef = Ref.chatMessages.child(room.id).push();
    // 한번에 여러개 같이 저장
    multiUpdateData[chatMessageRef.path] = chatMessageData;

    /// 한번에 여러개 노드 저장
    // See reference for the multi-path update.
    // Reference: https://firebase.google.com/docs/database/flutter/read-and-write#updating_or_deleting_data
    await rtdb.ref().update(multiUpdateData);

    /// 1:1 채팅방이면, 상대방의 이름과 사진을 내 채팅방 정보에 저장한다.
    /// 이것은, 상대방의 채팅방 목록에서 상대방의 이름과 사진을 보여주기 위해서이다.
    /// 실시간으로 uid 로 상대방의 정보를 가져와서 보여주어도 되지만, 더 빠른 목록을 위해서 이렇게 한다.
    /// 다만, 여기서는 채팅 메시지가 이미 전달된 다음에, 채팅방 정보를 업데이트하므로, 데이터 반응 속도는 신경쓰지 않아도 된다.
    if (room.isSingleChat) {
      final otherUid = room.otherUserUid!;
      final name = await UserModel.getField(otherUid, Code.displayName);
      final photoUrl = await UserModel.getField(otherUid, Code.photoUrl);
      joinRef(myUid!, singleChatRoomId(otherUid)).update({
        'name': name,
        'photoUrl': photoUrl,
      });
    }

    /// URL Preview 업데이트
    updateUrlPreview(chatMessageRef, text);
  }

  /// URL Preview 업데이트
  ///
  /// 채팅 메시지 자체에 업데이트하므로, 한번만 가져온다.
  Future updateUrlPreview(DatabaseReference ref, String? text) async {
    if (text == null || text == '') {
      return;
    }

    /// Update url preview
    final model = UrlPreviewModel();
    await model.load(text);

    if (model.hasData) {
      final data = {
        'previewUrl': model.firstLink!,
        if (model.title != null) 'previewTitle': model.title,
        if (model.description != null) 'previewDescription': model.description,
        if (model.image != null) 'previewImageUrl': model.image,
      };
      await ref.update(data);
    }
  }

  Map<String, dynamic> _getMultiUpdateForChatJoinLastMessage({
    String? text,
    String? url,
  }) {
    Map<String, dynamic> multiUpdateData = {};
    final epoch = DateTime.now().millisecondsSinceEpoch;

    for (final e in room.users?.entries.toList() ?? []) {
      final uid = e.key;
      multiUpdateData[joinPath(room.id, uid)] = _lastMessage(
        text: text,
        url: url,
        newMessage: uid == myUid ? null : ServerValue.increment(1),

        /// -1 을 order 앞에 붙여주는 이유는 읽지 않은 메시지가 있는 채팅방을 상단에 표시하기 위해서이다.
        /// 채팅방을 확인하면, 앞의 -1을 빼고, 그냥 -epoch 를 order 에 저장한다.
        order: uid == myUid ? -epoch : -int.parse("1$epoch"),
      );
    }

    return multiUpdateData;
  }

  /// 각 채팅방 멤버의 채팅방 목록에 마지막 채팅 정보 업데이트
  ///
  /// singleChatOrder 와 groupChatOrder 를 업데이트해야 한다. openChatOrder 는 업데이트 하지 않는다.
  ///
  /// [receiverUid] is the one who will receive the message.
  // static Future<Map<String, dynamic>> _lastMessage({
  Map<String, dynamic> _lastMessage({
    String? text,
    String? url,
    required dynamic newMessage,
    required int order,
  }) {
    // chat room info
    final data = {
      /// 그룹 채팅방 이름 또는 보내는 사람 이름
      'name': room.isSingleChat ? UserService.instance.user?.displayName : (room.name ?? ''),

      /// 1:1 채팅에서는 마지막 보낸 사람 사진 (나중에 덮어 쓰여질 수 있음.)
      /// 그룹 채팅에서는 방 사진.
      'photoUrl': room.isSingleChat ? UserService.instance.user?.photoUrl : room.photoUrl,

      /// 그룹 채팅의 경우, 사용자 수
      'noOfUsers': room.isGroupChat ? room.users?.length : null,

      /// 마지막 채팅 메시지
      'text': text,
      'url': url,
      'updatedAt': ServerValue.timestamp,
      'newMessage': newMessage,
      Code.groupChatOrder: room.isGroupChat ? order : null,
      Code.singleChatOrder: room.isSingleChat ? order : null,
      //
      'order': order,
    };
    return data;
  }

  /// 채팅방 나가기 (Exit the chat room)
  ///
  /// 상대방의 채팅방 목록에서는 삭제하지 않고, 나의 채팅방 목록에서만 삭제한다.
  /// It is deleted only from my chat room list without removing it from the other person's chat room list.
  /// 즉, 상대방은 모르게 한다. (In other words, the other person remains unaware.)
  ///
  /// For 1:1 chat, just remove the chat room node from /chat-rooms/{myUid}/{otherUid}
  /// For group chat, remove the chat room node from /chat-rooms/{myUid}/{groupChatId}
  ///   and remove my uid from /chat-rooms/{gropChatId}/users/{myUid}
  leave() {
    joinRef(myUid!, room.id).remove();
    roomUserRef(room.id, myUid!).remove();
    // 채팅 방에 인원이 더 이상 없으면, 채팅 방을 삭제한다.
    // If there are no more people in the chat room, the chat room is deleted.
    room.deleteIfNoUsers();
  }

  /// 채팅방 메시지 순서
  ///
  /// 채팅방의 메시지 순서(order)를 담고 있는 [ChatService.instance.roomMessageOrder] 를 초기화 한다.
  ///
  /// 첫 메시지에는 0의 값을 지정하고,
  /// 그 다음 메시지에는 [order] 를 입력 받아 더 작은 값으로 지정한다.
  resetRoomMessageOrder({required int? order}) async {
    if (ChatService.instance.roomMessageOrder[room.id] == null) {
      ChatService.instance.roomMessageOrder[room.id] = 0;
    }
    if (order != null && order < ChatService.instance.roomMessageOrder[room.id]!) {
      ChatService.instance.roomMessageOrder[room.id] = order;
    }
  }

  /// 채팅방 정보 `/chat-rooms/$uid/$otherUid` 에서 newMessage 를 0 으로 초기화 한다.
  ///
  /// 사용처: 내가 현재 채팅방에 들어왔으니, 현재 채팅방의 새로운 메시지가 없다는 것을 표시 할 때 사용.
  ///
  /// 특히, 내가 채팅방에 들어가 갈 때, 또는 내가 채팅방에 들어가 있는데, 새로운 메시지가 전달되어져 오는 경우,
  /// 이 함수가 호출되어 그 채팅방의 새 메시지 수를 0으로 초기화 할 때 사용한다.
  ///
  /// setting the order into -updatedAt (w/out the "1")
  /// this is used to order by unread/read messages then by updatedAt
  /// w/out the "1" it means it has been read.
  ///
  /// 주의, 로그인을 하지 않은 상태이면 그냥 리턴한다.
  /// 예를 들어, 메인 페이지에 (로그인을 하기 전에) 채팅방을 보여주는 경우,
  Future<void> resetMyRoomNewMessage({
    int? order,
  }) async {
    if (myUid == null) {
      return;
    }
    final myJoinRef = joinRef(myUid!, room.id);
    // the problem is when this is too fast
    myJoinRef.update({
      'newMessage': null,
      'order': order ?? -int.parse('${room.updatedAt ?? room.createdAt ?? 0}'),
    });

    // wait for 1 second before updating the order

    // .then((value) {
    //   myJoinRef.child('updatedAt').get().then((updatedAt) {
    //     myJoinRef.update({'order': -int.parse('${(updatedAt.value ?? "0") as int}')});
    //   });
    // });
    // print('--> resetRoomNewMessage: $roomId');
  }

  /// 누군가 채팅을 해서, 새로운 메시지가 전달되어져 왔는지 판단하는 함수이다.
  ///
  /// 채팅방 목록을 하는 [RChatMessageList] 에서 사용 할 수 있으며, 새로운 메시지가 전달되었으면, newMessage 를
  /// 0 으로 저장해야 할 지, 판단하는 함수이다.
  ///
  /// [messageRoomId] 는 채팅 메시지를 저장하는 노드 ID(채팅방 ID가 아님),
  ///
  /// [snapshot] 은 채팅방 안에서, 페이지 단위로 채팅을 로딩 할 때, 그 채팅 노드를 담고 있는
  /// [FirebaseDatabaseQueryBuilder] 의 snapshot 이다.
  /// 처음 채팅방 접속 또는 채팅방을 위로 스크롤 할 때, 또는 누군가 새로운 채팅을 할 때, 새로운 채팅 목록 정보를 가져와서
  /// 화면에 보여줄 때, 이 함수가 호출된다. 이 때, [snapshot] 이 그 채팅 메시지 목록을 가지고 있다.
  ///
  ///
  /// 이 함수는, 누군가 채팅을 해서 (내가 채팅한 것이 아닌), 새로운 메시가 전달되었다면 true 를 리턴한다. 화면 스크롤이나, 처음 채팅방 접속해서
  /// 채팅 메시지를 가져오는 경우에는 false 를 리턴한다.
  ///
  /// 처음 로딩(첫 페이지)하거나, Hot reload 를 하거나, 채팅방을 위로 스크롤 업 해서 이전 데이터 목록을 가져오는 경우에는
  /// false 를 리턴한다.
  ///
  /// 채팅방에 들어가 있는 상태에서 새로운 메시지를 받으면, "newMessage: 를 0 으로 초기화 하기 위해서이다. 즉,
  /// 채팅 메시지를 읽음으로 표시하기 위해서이다.
  ///
  /// 문제, 앱을 처음 실행하면, [chatRoomMessgaeOrder] 에는 아무런 값이 없다. 이 때, 새로운 메시지가 있는
  /// 채팅방으로 접속을 하면, `if (currentMessageOrder == 0 ) return fales` 에 의해서 항상 false 가
  /// 리턴된다. 그래서, 처음 채팅방에 진입을 할 때에는 [snapshot.isFetching] 을 통해서 newMessage 를 초기화
  /// 해야 한다.
  bool isLoadingNewMessage(String messageRoomId, FirebaseQueryBuilderSnapshot snapshot) {
    if (snapshot.docs.isEmpty) return false;

    final lastMessage = ChatMessageModel.fromSnapshot(snapshot.docs.first);
    final lastMessageOrder = lastMessage.order as int;

    final currentMessageOrder = service.getRoomMessageOrder(messageRoomId);

    /// 이전에 로드된 채팅 메시지가 없는가? 누군가 채팅을 한 것이 아니라, 채팅방에 접속해서, 처음 로드된 것이므로 false 를 리턴한다.
    ///
    if (currentMessageOrder == 0) {
      return false;
    }

    /// 이전에 로드된 채팅 메시지가 있는가?
    /// 그렇다면 이전에 로드된 채팅 메시지의 order 와 현재 로드된 채팅 메시지의 order 를 비교한다.
    /// 만약 이전에 로드된 채팅 메시지의 order 가 현재 로드된 채팅 메시지의 order 보다 크다면,
    /// 누군가 채팅을 해서 새로운 메시지가 있다는 것이다.
    ///
    /// This return false when I am the one who sent message.
    if (currentMessageOrder > lastMessageOrder) {
      return true;
    }

    /// 이전에 로드된 채팅 메시지가 있지만, 새로운 채팅 메시지를 받지 않았다면, false 를 리턴한다.
    /// 위로 스크롤 하는 경우, 이 메시지가 발생 할 수 있다.
    return false;
  }

  /// 채팅방 입장
  ///
  /// [join] 메소드를 호출 할 때에는 [room] 정보가 실제 DB 로 업데이트되어져야 한다. 실제로
  /// [subscribeRoomUpdate] 에서 [room] 정보를 업데이트 후, [join] 메소드를 호출하고 있다.
  ///
  /// 채팅방 문서(/chat-rooms/{roomId})가 존재하지 않아도 joinRoom() 을 호출하면, 채팅방 문서가 생성된다.
  /// 1:1 채팅에서는, 맨 처음 채팅방이 만들어지고, 입장 할 때, 채팅방이 존재하지 않는 상태이다.
  /// For group chat, the user uid is added to /chat-rooms/{groupChatId}/users/{[uid]: true}
  /// For 1:1 chat, create a chat room info under my chat room list only. Not the other user's.
  ///
  /// Note, it's not that harmful to set the same uid to true over again and if it happens
  /// only one time when the user enters the chat room.
  ///
  /// 로그인을 하지 않았으면, 그냥 리턴한다.
  /// 이미 방에 들어가 있는 상태이면 그냥 리턴한다.
  ///
  ///
  Future join() async {
    if (myUid == null) {
      // 로그인을 하지 않았으면 그냥 리턴
      // throw Exception('ChatModel::join() -> Login first -> myUid is null');
      throw ErrorCode(Code.notLoggedIn);
    }

    // 채팅방이 인증 회원 전용 입장이면, 인증 회원이 아니면 그냥 리턴
    if (room.isVerifiedOnly && UserService.instance.user?.isVerified != true) {
      throw ErrorCode(Code.chatRoomNotVerified);
    }

    // 내가 이미 방에 들어가 있는 상태이면 그냥 리턴
    if (room.users?.containsKey(myUid) == true) return;
    dog('ChatService.instance.joinRoom: Not joined, yet. Joing now ...');

    final otherUserUid = room.otherUserUid;

    // 나를 채팅방 정보의 사용자 목록에 추가
    await room.ref.child('users').child(myUid!).set(true);

    // 1:1 채팅이면, 채팅방의 사용자 목록에, 다른 사용자 아이디를 추가해 준다.
    if (room.isSingleChat) {
      if (room.users?.containsKey(otherUserUid) != true) {
        await room.ref.child('users').child(otherUserUid!).set(true);
      }
    } else {
      // 그룹 채팅방이면, noOfUsers 를 업데이트 한다.
      await room.ref.child('noOfUsers').set((room.users?.length ?? 0) + 1);
    }

    /// 나의 채팅방 목록에 저장할 채팅방 정보
    ///
    final order = -int.parse('${room.updatedAt ?? room.createdAt ?? 0}');
    final data = {
      Code.name: room.isGroupChat ? room.name : '',
      Code.groupChatOrder: room.isGroupChat ? order : null,
      Code.singleChatOrder: room.isSingleChat ? order : null,
      Code.newMessage: null,
    };

    /// 1:1 채팅방의 경우, 상대방의 이름을 저장한다.
    if (otherUserUid != null) {
      final user = await UserModel.get(otherUserUid);
      data['name'] = user?.displayName;
    }

    // set order into -updatedAt (w/out "1")
    // it is important to know that updatedAt must not be updated
    // before this.
    data['order'] = order;
    await joinsRef.child(myUid!).child(room.id).update(data);
  }

  /// 현재 방 listen, unlisten
  StreamSubscription<DatabaseEvent>? roomSubscription;
  subscribeRoomUpdate({
    Function? onUpdate,
  }) {
    /// 현재 채팅방 listen
    roomSubscription = room.ref.onValue.listen((event) async {
      if (event.snapshot.exists) {
        // 채팅방이 존재하면, 채팅방 정보를 가져오고, 재 설정
        final room = ChatRoomModel.fromSnapshot(event.snapshot);
        resetRoom(room: room);
        dog('[2] 채팅방 정보 업데이트');
        onUpdate?.call();
      } else {
        // 채팅방이 존재하지 않으면, 채팅방을 생성
        // 그러면 위의 이벤트가 발생.
        await ChatRoomModel.create(roomId: room.id);
        dog('[1] 채팅방 생성');
      }
    });
  }

  unsubscribeRoomUpdate() {
    roomSubscription?.cancel();
  }
}
