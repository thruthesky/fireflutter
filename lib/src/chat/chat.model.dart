import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// Chat Model
///
/// 이 모델은 채팅방의 데이터 모델이 아니라, 로직을 담고 있는 로직 모델이다.
/// This model is not a data model for the chat room but a logic model containing the logic.
///
/// ChatService 에 모든 것을 다 집어 넣으면, 각 채팅 방마다 관리가 어렵고 동시에 두개의 채팅방을 열 수 없다.
/// If all the logic is squeezed inside the ChatService, it is not easy to
/// manage chat room. And it is very difficult to open more than one chat room at the same time.
/// So, [ChatModel] is created to manage the logic of each chat room. And it is
/// possible to open more than one chat room at the same time.
///

class ChatModel {
  /// Set the current room.
  ChatRoom room;
  FirebaseDatabase get rtdb => FirebaseDatabase.instance;
  DatabaseReference get roomsRef => rtdb.ref().child('chat-rooms');

  DatabaseReference roomRef(String roomId) => roomsRef.child(roomId);

  /// 전체 채팅방 ref
  DatabaseReference get messagesRef => ChatService.instance.messagesRef;

  /// 채팅방 1개 ref
  DatabaseReference messageRef({required String roomId}) =>
      ChatService.instance.messageRef(roomId: roomId);

  /// [roomUserRef] is the reference to the users node under the group chat room. Ex) /chat-rooms/{roomId}/users/{my-uid}
  DatabaseReference roomUserRef(String roomId, String uid) =>
      rtdb.ref().child('chat-rooms/$roomId/users/$uid');

  /// This is used to update the last message in the chat room list per user in /chat-joins
  /// /chat-joins/{uid}/{roomId}
  String joinPath(String roomId, String uid) => '/chat-joins/$uid/$roomId';

  get service => ChatService.instance;

  ChatModel({
    required this.room,
  });

  /// 각 채팅방 마다, 맨 마지막 채팅 메시지의 order 값을 가지고 있는 배열
  ///
  /// 참고, 이 변수를 통째로 ChatModel 로 이동하도록 하면, 보다 간결한 코딩이 가능해 질 수 있겠다.
  ///
  /// 이것은 채팅 메시지를 역순으로 목록하기 위해서 사용하는 것으로, 나중에 입력되는 메시지일 수록 더 적은 음수 값을 저장해야하는데,
  /// 메시지가 저장될 때 그 즉시, -1 로 저장하고,
  /// 나중에, "시간 * -1"을 해서 업데이트를 해준다.
  ///
  /// 채팅방의 메시지 순서(order)를 가져온다.
  /// 만약, [ChatService.instance.roomMessageOrder] 에 값이 없으면 0을 리턴한다.
  int messageOrder = 0;

  resetRoom({required ChatRoom room}) {
    this.room = room;
  }

  /// 채팅 메시지 전송
  ///
  /// [url] 은 업로드한 파일(사진) url 이다.
  ///
  /// [force] 는 강제로 메시지를 전송한다. 메시지를 전송하는 사용자가 disabled 나 blocked 되어져 있어도 강제로
  /// 메시지를 보낸다.
  ///
  /// Cache receiver's name and photoUrl.
  /// So, it can save the name and photoUrl on the single chat to reduce the number of database reads.
  /// Note that, it is not a map for support multi chat rooms.
  String? receiverName;
  String? receiverPhotoUrl;
  Future<void> sendMessage({
    String? text,
    String? url,
    bool force = false,
  }) async {
    if ((url == null || url.isEmpty) && (text == null || text.isEmpty)) return;

    /// 그룹 채팅방에서 차단된 사용자이면, 메시지를 전송하지 않고 에러를 낸다.
    if (room.blockedUsers.contains(myUid)) {
      throw FireFlutterException(
          Code.chatSendMessageBlockedUser, T.chatSendMessageBlockedUser);
    }

    /// 차단되면, 메시지를 전송하지 않고 에러를 낸다.
    if (force == false && UserService.instance.user?.isDisabled == true) {
      throw FireFlutterException(Code.disabled, T.disabledOnSendMessage);
    }

    /// 방에 입장하지 않은 상태이면, [force] 가 true 이더라도 메시지를 전송하지 않는다.
    if (room.joined == false) {
      throw FireFlutterException(
          Code.notJoined, 'chat.model.dart->sendMessage()');
    }

    /// 인증된 사용자만 URL 전송 옵션
    if (text?.hasUrl == true && room.urlVerifiedUserOnly && iam.notVerified) {
      throw FireFlutterException(Code.notVerified, T.notVerifiedMessage);
    }

    /// 인증된 사용자만 파일 전송 옵션
    if (url != null && room.uploadVerifiedUserOnly && iam.notVerified) {
      throw FireFlutterException(Code.notVerified, T.notVerifiedMessage);
    }

    /// 채팅 메시지 순서를 -1 (감소) 한다.
    messageOrder--;

    /// Save chat message under `/chat-messages`.
    ///
    // 저장할 채팅 데이터
    Map<String, dynamic> chatMessageData = {
      'uid': myUid,
      if (text != null) 'text': text,
      if (url != null) 'url': url,
      'order': messageOrder,
      'createdAt': ServerValue.timestamp,
    };

    /// Warning! This data does not represent the actual data in the database. It is a temporary data
    /// made for the purpose of manipulating the chat message data before saving it.
    if (ChatService.instance.beforeMessageSent != null) {
      chatMessageData =
          await ChatService.instance.beforeMessageSent!(chatMessageData, this);
    }

    /// 1:1 채팅방이면, 상대방의 이름과 사진을 내 채팅방 정보에 저장한다.
    /// 이것은, 상대방의 채팅방 목록에서 상대방의 이름과 사진을 보여주기 위해서이다.
    /// 실시간으로 uid 로 상대방의 정보를 가져와서 보여주어도 되지만, 더 빠른 목록을 위해서 이렇게 한다.
    /// 다만, 여기서는 채팅 메시지가 이미 전달된 다음에, 채팅방 정보를 업데이트하므로, 데이터 반응 속도는 신경쓰지 않아도 된다.

    /// @thruthesky 24-05-28
    if (room.isSingleChat && receiverName == null) {
      final otherUid = room.otherUserUid!;
      receiverName = (await User.getField(otherUid, Field.displayName)) ?? '';
      receiverPhotoUrl = await User.getField(otherUid, Field.photoUrl);
    }

    /// 참고, 실제 메시지를 보내기 전에, 채팅방 자체를 먼저 업데이트 해 버린다.
    ///
    /// 상황 발생, A 가 B 가 모두 채팅방에 들어가 있는 상태에서
    /// A 가 B 에게 채팅 메시지를 보내면, 그 즉시 B 의 채팅방 목록이 업데이트되고,
    /// B 의 채팅방의 newMessage 가 0 으로 된다.
    /// 그리고, 나서 updateJoin() 을 하면, B 의 채팅 메시지가 1이 되는 것이다.
    /// 즉, 0이 되어야하는데 1이 되는 상황이 발생한다. 그래서, updateJoin() 이 먼저 호출되어야 한다.
    Map<String, dynamic> multiUpdateData =
        _getMultiUpdateForChatJoinLastMessage(
      text: chatMessageData["text"],
      url: chatMessageData["url"],
    );

    /// Place to save the chat message data
    ///
    /// 채팅 메시지를 저장 할 경로
    final chatMessageRef = ChatMessage.messagesRef(roomId: room.id).push();

    /// Save multiple nodes at once
    ///
    /// 한번에 여러 노드를 같이 저장
    multiUpdateData[chatMessageRef.path] = chatMessageData;

    ///
    /// See reference for the multi-path update.
    /// Reference: https://firebase.google.com/docs/database/flutter/read-and-write#updating_or_deleting_data
    await rtdb.ref().update(multiUpdateData);

    /// After chat message is saved (meaning after chat message is sent), call the callback function
    ChatService.instance.afterMessageSent?.call(
      ChatMessage.fromJson({
        'key': chatMessageRef.key,
        'ref': chatMessageRef,
        ...chatMessageData,
      }),
    );

    /// 1:1 채팅방이면, 상대방의 이름과 사진을 내 채팅방 정보에 저장한다.
    /// 이것은, 상대방의 채팅방 목록에서 상대방의 이름과 사진을 보여주기 위해서이다.
    /// 실시간으로 uid 로 상대방의 정보를 가져와서 보여주어도 되지만, 더 빠른 목록을 위해서 이렇게 한다.
    /// 다만, 여기서는 채팅 메시지가 이미 전달된 다음에, 채팅방 정보를 업데이트하므로, 데이터 반응 속도는 신경쓰지 않아도 된다.

    /// @thruthesky 24-05-28
    // if (room.isSingleChat) {
    //   final otherUid = room.otherUserUid!;
    //   final name = await User.getField(otherUid, Field.displayName);
    //   final photoUrl = await User.getField(otherUid, Field.photoUrl);
    //   ChatJoin.joinRef(myUid!, singleChatRoomId(otherUid)).update({
    //     'name': name,
    //     'photoUrl': photoUrl,
    //   });
    // }

    /// URL Preview Update
    ///
    /// If there is a url inside the text, it will display site preview.
    /// Don't do this before sending message since it will slow down the process.
    updateUrlPreview(chatMessageRef, text);

    /// 2024. 01. 26 - 푸시 알림을 클라우드 함수로 보낸다. 아래 코드는 03. 03. 이후 삭제한다.
    if (room.isGroupChat) {
      dog('group chat');

      /// Send push notification to the room users
      ///
      /// Dont' send push notification if the user truned off the push notification.
      // final List<String> uids = room.users!.entries.toList().fold([], (p, e) {
      //   if (room.users![e.key] != true) return p;
      //   p.add(e.key);
      //   return p;
      // });

      /// sending notification to the list of uids
      // await MessagingService.instance.sendTo(
      //   uids: uids,
      //   title: room.name ?? '',
      //   body: text ?? "사진을 업로드하였습니다.",
      //   image: url,
      // );
    } else if (room.isSingleChat) {
      /// sending notification for single chat
      // final uid = room.otherUserUid;
      // if (room.users![uid] == true) {
      //   await MessagingService.instance.sendTo(
      //       uid: uid,
      //       title: '${UserService.instance.user?.displayName}',
      //       body: text ?? "사진을 업로드하였습니다.",
      //       image: url);
      // }
    }
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

  /// Prepares a map that will be used to update the chat joins
  Map<String, dynamic> _getMultiUpdateForChatJoinLastMessage({
    String? text,
    String? url,
  }) {
    Map<String, dynamic> multiUpdateData = {};
    final epoch = DateTime.now().millisecondsSinceEpoch;

    /// [e] is the {uid: true} pair for each user in the room. and if it's true, the user gets notification.
    for (final e in room.users?.entries.toList() ?? []) {
      final uid = e.key;

      /// Update the last message in the chat room list per user in /chat-joins/{uid}/{roomId}
      multiUpdateData[joinPath(room.id, uid)] = _chatJoinLastMessage(
        uid: uid,
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
  /// [uid] is the location of the /chat-joins/{uid}/{roomId} node. This may be login user's uid or
  /// any other user's uid in the room.
  ///
  Map<String, dynamic> _chatJoinLastMessage({
    required String uid,
    String? text,
    String? url,
    required dynamic newMessage,
    required int order,
  }) {
    /// chat room info
    ///
    String? name;
    String? photoUrl;

    if (room.isGroupChat) {
      name = room.name ?? '';
      photoUrl = room.iconUrl;
    } else {
      if (uid == myUid) {
        name = receiverName;
        photoUrl = receiverPhotoUrl;
      } else {
        name = my?.displayName;
        photoUrl = my?.photoUrl;
      }
    }

    final data = {
      /// 그룹 채팅방 이름 또는 보내는 사람 이름
      'name': name,

      /// 1:1 채팅에서는 마지막 보낸 사람 사진 (나중에 덮어 쓰여질 수 있음.)
      /// 그룹 채팅에서는 채팅방 아이콘 사진.
      'photoUrl': photoUrl,

      /// 그룹 채팅의 경우, 사용자 수
      'noOfUsers': room.isGroupChat ? room.users?.length : null,

      /// 마지막 채팅 메시지
      'text': text,
      'url': url,
      'updatedAt': ServerValue.timestamp,
      'newMessage': newMessage,
      Field.groupChatOrder: room.isGroupChat ? order : null,
      Field.singleChatOrder: room.isSingleChat ? order : null,
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
    ChatJoin.joinRef(myUid!, room.id).remove();
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
  resetMessageOrder({required int? order}) async {
    if (order != null && order < messageOrder) {
      messageOrder = order;
    }
  }

  /// 채팅방 정보 `/chat-joins/$uid/$otherUid` 에서 newMessage 를 0 으로 초기화 한다.
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
  ///
  /// [join] 은 맨 처음 채팅방에 입장 할 때, 한번만 전달되주면 된다. 새 메시지가 없다는 표시를 하기 위해서이다.
  ///
  Future<void> resetNewMessage({
    int? order,
    ChatRoom? join,
  }) async {
    if (myUid == null) {
      return;
    }

    int? singleChatOrder, groupChatOrder;

    /// If [join] is null, the user is re-entering the chat room.
    ///
    /// 새 메시지가 있다는 뜻인 -11 을 그냥 -1 로 변경한다.
    ///
    /// order 값 맨 앞에 1을 추가한 것이다. 예를 들어, order 값이 -12345 와 같다면 맨 앞에 1을 추가해서
    /// -112345 가 된 것이다. 즉, 맨 앞의 -11 을 그냥 -1 로 바꾸는 것이다.
    if (join != null) {
      if (join.singleChatOrder.toString().contains('-11')) {
        singleChatOrder =
            int.parse(join.singleChatOrder.toString().replaceAll('-11', '-1'));
      }
      if (join.groupChatOrder.toString().contains('-11')) {
        groupChatOrder =
            int.parse(join.groupChatOrder.toString().replaceAll('-11', '-1'));
      }

      /// For all chat room list (including single & group), uses 'order' field to sort the list.
      if (join.order.toString().contains('-11')) {
        order = int.parse(join.order.toString().replaceAll('-11', '-1'));
      }
    }

    final myJoinRef = ChatJoin.joinRef(myUid!, room.id);
    myJoinRef.update({
      Field.newMessage: null,
      if (singleChatOrder != null) Field.singleChatOrder: singleChatOrder,
      if (groupChatOrder != null) Field.groupChatOrder: groupChatOrder,
      if (order != null) Field.order: order,
    });
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
  bool isLoadingNewMessage(
      String messageRoomId, FirebaseQueryBuilderSnapshot snapshot) {
    if (snapshot.docs.isEmpty) return false;

    final lastMessage = ChatMessage.fromSnapshot(snapshot.docs.first);
    final lastMessageOrder = lastMessage.order as int;

    final currentMessageOrder = messageOrder;

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

  /// 현재 방 listen, unlisten
  StreamSubscription<DatabaseEvent>? roomSubscription;
  subscribeRoomUpdate({
    Function? onUpdate,
  }) {
    /// 현재 채팅방 listen
    roomSubscription = room.ref.onValue.listen((event) async {
      if (event.snapshot.exists) {
        // 채팅방이 존재하면, 채팅방 정보를 가져오고, 재 설정
        final room = ChatRoom.fromSnapshot(event.snapshot);
        resetRoom(room: room);
        dog('[2] 채팅방 정보 업데이트');
        onUpdate?.call();
      } else {
        // 채팅방이 존재하지 않으면, 채팅방을 생성
        // 그러면 위의 이벤트가 발생.
        await ChatRoom.create(roomId: room.id);
        dog('[1] 채팅방 생성');
      }
    });
  }

  unsubscribeRoomUpdate() {
    roomSubscription?.cancel();
  }
}
