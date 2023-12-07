import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// RChat
///
class RChat {
  /// Firebase Realtime Database Chat Functions
  ///
  ///

  /// This one is used for each users
  /// /chat-rooms/{uid}/{chatRoomId}
  static const String chatRoomsPath = 'chat-rooms';

  /// This one is used for chat room details
  /// /chat-room-details/{chatRoomId}/...
  static const String chatRoomDetailsPath = 'chat-room-details';

  static DatabaseReference userRoomsRef({required String uid}) => rtdb.ref().child('$chatRoomsPath/$uid');
  static DatabaseReference userRoomRef({required String uid, required String roomId}) =>
      userRoomsRef(uid: uid).child(roomId);
  static DatabaseReference roomDetailsRef({required String roomId}) => rtdb.ref().child('$chatRoomDetailsPath/$roomId');
  static DatabaseReference messageRef({required String roomId}) => roomDetailsRef(roomId: roomId).child('messages');
  static DatabaseReference roomUsersRef({required String roomId}) => roomDetailsRef(roomId: roomId).child('users');

  ///
  /// 참고, roomId 를 입력 받지 않고, global 영역의 변수의 것을 사용한다. 이렇게 하는 이유는 화면 깜빡임을 줄이기 위해서
  /// 이다. roomId 가 변경 될 때 마다, 채팅 메시지 입력 창 위젯과 같은 위젯들에 roomId 를 전달하기 위해서, 해당 위젯들을
  /// rebuild 하는 상황이 발생하는데, global 영역에 roomId 를 저장하므로서 위젯 rebuild 를 줄여, 화면 깜빡임을 줄이는
  /// 역할을 한다.
  ///
  /// Translate In English:
  /// Note, we use the one in the global area without receiving roomId as input.
  /// The reason for doing this is to reduce screen flickering.
  /// Whenever the roomId changes, the widgets such as the chat message input box widget are rebuilt.
  /// By storing roomId in the global area, we reduce widget rebuilds and reduce screen flickering.
  ///
  ///
  static String roomId = 'all';

  static bool isGroupChat = true;

  /// 각 채팅방 마다 -1을 해서 order 한다.
  ///
  /// 더 확실히 하기 위해서는 order 를 저장 할 때, 이전 order 의 -1 로 하고, 저장이 된 후, createAt 의 -1 을 해 버린다.
  static final Map<String, int> roomMessageOrder = {};

  static setRoom(String roomId, bool isGroupChat) {
    RChat.roomId = roomId;
    RChat.isGroupChat = isGroupChat;
  }

  /// 채팅 메시지 전송
  ///
  ///
  static Future<void> sendMessage({
    String? text,
    String? url,
  }) async {
    if ((url == null || url.isEmpty) && (text == null || text.isEmpty)) return;

    if (my?.isDisabled == true) {
      toast(title: 'Notice', message: 'Your account is disabled. Please contact admin.');
      return;
    }

    roomMessageOrder[roomId] = (roomMessageOrder[roomId] ?? 0) - 1;

    /// 참고, 실제 메시지를 보내기 전에, 채팅방 자체를 먼저 업데이트 해 버린다.
    ///
    /// 상황 발생, A 가 B 가 모두 채팅방에 들어가 있는 상태에서
    /// A 가 B 에게 채팅 메시지를 보내면, 그 즉시 B 의 채팅방 목록이 업데이트되고,
    /// B 의 채팅방의 newMessage 가 0 으로 된다.
    /// 그리고, 나서 updateRoom() 을 하면, B 의 채팅 메시지가 1이 되는 것이다.
    /// 즉, 0이 되어야하는데 1이 되는 상황이 발생한다. 그래서, updateRoom() 이 먼저 호출되어야 한다.
    updateRoom(text: text, url: url);

    // dog('Room Id: $roomId');

    await messageRef(roomId: roomId).push().set({
      'uid': myUid,
      if (text != null) 'text': text,
      if (url != null) 'url': url,
      'order': RChat.roomMessageOrder[roomId],
      'createdAt': ServerValue.timestamp,
    });
  }

  /// Update chat room
  static void updateRoom({
    String? text,
    String? url,
  }) async {
    // dog('is group chat: ${isGroupChat(roomId)}');
    if (isGroupChat) {
      /// 그룹 채팅방 업데이트
      roomDetailsRef(roomId: roomId).update({
        'text': text,
        'url': url,
        'order': RChat.roomMessageOrder[roomId],
        'updatedAt': ServerValue.timestamp,
        'newMessage': 0,
        // 'isGroupChat': isGroupChat(roomId),
        'isGroupChat': true,
      });

      // TODO send all users

      // chat room under my room list
      // userRoomRef(uid: myUid!, roomId: roomId).set({
      //   'text': text,
      //   'url': url,
      //   'order': RChat.roomMessageOrder[roomId],
      //   'updatedAt': ServerValue.timestamp,
      //   'newMessage': 0,
      //   // 'isGroupChat': isGroupChat(roomId),
      //   'isGroupChat': true,
      // });

      final snapshot = await roomUsersRef(roomId: roomId).get();
      final users = Map<String, bool>.from((snapshot.value ?? {}) as Map)
          .entries
          .where((element) => element.value == true)
          .map((e) => e.key)
          .toList();
      //  do userRoomRef for each user
      for (var uid in users) {
        userRoomRef(uid: uid, roomId: roomId).set({
          'text': text,
          'url': url,
          'order': RChat.roomMessageOrder[roomId],
          'updatedAt': ServerValue.timestamp,
          'newMessage': 0,
          // 'isGroupChat': isGroupChat(roomId),
          'isGroupChat': true,
        });
      }
    } else {
      String otherUid = otherUidFromRoomId(roomId);

      // TODO do dry
      // chat room under my room list
      userRoomRef(uid: myUid!, roomId: otherUid).set({
        'text': text,
        'url': url,
        'order': RChat.roomMessageOrder[roomId],
        'updatedAt': ServerValue.timestamp,
        'newMessage': 0,
        // 'isGroupChat': isGroupChat(roomId),
        'isGroupChat': false,
      });

      // chat room info update under other user room list
      userRoomRef(uid: otherUid, roomId: myUid!).update({
        'text': text,
        'url': url,
        'order': RChat.roomMessageOrder[roomId],
        'updatedAt': ServerValue.timestamp,
        'newMessage': ServerValue.increment(1),
        // 'isGroupChat': isGroupChat(roomId),
        'isGroupChat': false,
      });
    }
  }

  /// 채팅방 나가기
  ///
  /// 상대방의 채팅방 목록에서는 삭제하지 않고, 나의 채팅방 목록에서만 삭제한다.
  /// 즉, 상대방은 모르게 한다.
  ///
  /// For 1:1 chat, just remove the chat room node from /chat-rooms/{myUid}/{otherUid}
  /// For group chat, remove the chat room node from /chat-rooms/{myUid}/{groupChatId}
  ///   and remove my uid from /chat-rooms/{gropChatId}/users/{myUid}
  static leaveRoom({
    required RChatRoomModel room,
  }) {
    if (room.isGroupChat == true) {
      /// 그룹 채팅방에서 나가기
      leaveGroupChat(room: room);
    } else {
      /// 1:1 채팅방에서 나가기
      leaveSingleChat(room: room);
    }
  }

  /// Leaving the Group Chat means
  /// removing myUid in /chat-rooms/{groupChatId}/users/{[uid]: true}
  /// and removing the chat room node from /chat-rooms/{myUid}/{groupChatId}
  static leaveGroupChat({required RChatRoomModel room}) {
    /// 그룹 채팅방에서 나가기
    roomUsersRef(roomId: room.key).child(myUid!).remove();
    userRoomsRef(uid: myUid!).child(room.key).remove();
  }

  /// Leaving the Single Chat means
  /// removing the chat room node from /chat-rooms/{myUid}/{otherUid}
  static leaveSingleChat({required RChatRoomModel room}) {
    /// 1:1 채팅방에서 나가기
    userRoomRef(uid: myUid!, roomId: room.key).remove();
  }

  /// 채팅방의 메시지 순서(order)를 담고 있는 [RChat.roomMessageOrder] 를 초기화 한다.
  static resetRoomMessageOrder({required String roomId, required int? order}) async {
    if (RChat.roomMessageOrder[roomId] == null) {
      RChat.roomMessageOrder[roomId] = 0;
    }
    if (order != null && order < RChat.roomMessageOrder[roomId]!) {
      RChat.roomMessageOrder[roomId] = order;
    }
  }

  /// 채팅방의 메시지 순서(order)를 가져온다.
  /// 만약, [RChat.roomMessageOrder] 에 값이 없으면 0을 리턴한다.
  static int getRoomMessageOrder(String roomId) {
    return RChat.roomMessageOrder[roomId] ?? 0;
  }

  /// 채팅방 정보 `/chat-rooms/$uid/$otherUid` 에서 newMessage 를 0 으로 초기화 한다.
  /// Reset the newMessage to 0 in `/chat-rooms/$uid/$otherUid`
  /// This will reset the Room New Message in chat room info `/chat-rooms/$uid/$roomId`
  static Future<void> resetRoomNewMessage({required String roomId}) async {
    await userRoomRef(uid: myUid!, roomId: isGroupChat ? roomId : otherUidFromRoomId(roomId)).update(
      {
        'newMessage': 0,
        'isGroupChat': isGroupChat,
      },
    );
    // print('--> resetRoomNewMessage: $roomId');
  }

  /// 새로운 메시지가 전달되어져 왔는지 판단하는 함수이다.
  ///
  /// 채팅방 목록을 하는 [RChatMessageList] 에서 사용 할 수 있으며, 새로운 메시지가 전달되었으면, newMessage 를
  /// 0 으로 저장해야 할 지, 판단하는 함수이다.
  ///
  /// [roomId] 는 채팅방의 아이디이며, [snapshot] 은 [FirebaseDatabaseQueryBuilder] 의 snapshot 이다.
  ///
  /// 새로운 메시가 전달되었다면 true 를 리턴한다.
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
  static bool isLoadingForNewMessage(String roomId, FirebaseQueryBuilderSnapshot snapshot) {
    if (snapshot.docs.isEmpty) return false;

    final lastMessage = RChatMessageModel.fromSnapshot(snapshot.docs.first);
    final lastMessageOrder = lastMessage.order as int;

    final currentMessageOrder = getRoomMessageOrder(roomId);

    /// 이전에 로드된 채팅 메시지가 없는가? 그렇다면 처음 로드된 것이므로 false 를 리턴한다.
    if (currentMessageOrder == 0) {
      return false;
    }

    /// 이전에 로드된 채팅 메시지가 있는가?
    /// 그렇다면 이전에 로드된 채팅 메시지의 order 와 현재 로드된 채팅 메시지의 order 를 비교한다.
    /// 만약 이전에 로드된 채팅 메시지의 order 가 현재 로드된 채팅 메시지의 order 보다 크다면, 새로운 메시지가 있다는 것이다.
    if (currentMessageOrder > lastMessageOrder) {
      return true;
    }

    /// 이전에 로드된 채팅 메시지가 있지만, 새로운 채팅 메시지를 받지 않았다면, false 를 리턴한다.
    /// 위로 스크롤 하는 경우, 이 메시지가 발생 할 수 있다.
    return false;
  }

  /// 일대일 채팅방 ID 를 만든다.
  ///
  /// [myUid] 와 [otherUserUid] 를 정렬해서 합친다. 채팅 메시지를 저장할 /chat-messages/ 노드의 하위 노드 아이디가 된다.
  ///
  static String singleChatRoomId(String otherUserUid) {
    final uids = [myUid, otherUserUid];
    uids.sort();
    return uids.join('-');
  }

  /// For group chat, the login user uid is added to /chat-rooms/{groupChatId}/users/{[uid]: true}
  ///
  /// Note, it's not that harmful to set the same uid to true again if it happens only on the chat room entering.
  ///
  ///
  static Future joinRoom({required RChatRoomModel room}) async {
    if (room.isGroupChat == true) {
      final isAlreadyJoined = await roomUsersRef(roomId: room.key).child(myUid!).get();
      if (isAlreadyJoined.value != true) {
        roomUsersRef(roomId: room.key).child(myUid!).set(true);
        updateRoom(text: room.text, url: room.url);
        // TODO protocol
      }
    }
  }
} // EO RChat
