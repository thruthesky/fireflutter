import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class ChatRoomModel {
  final DatabaseReference ref;
  String key;
  String? text;
  String? url;
  int? updatedAt;
  int? createdAt;
  int? newMessage;
  int? singleChatOrder;
  int? groupChatOrder;
  int? openGroupChatOrder;
  String? name;

  /// 그룹 채팅방을 대표하는 아이콘 사진을 저장한다.
  String? iconUrl;

  /// 채팅방 목록에 표시할 사진을 저장한다.
  ///
  /// 1:1 채팅에서 A 가 채팅 메시지를 전송하면, A 의 chat-joins 에는 B 의 사진이 들어가고, B 의 chat-joins
  /// 에는 A 의 사진이 들어간다.
  ///
  /// 그룹 채팅에서는 iconUrl 을 chat-joins/<uid>/<roomId> 에 저장한다.
  String? photoUrl;
  String? description;
  String? master;

  /// 회원 인증한 사용자만 입장 가능하도록 하는 옵션
  bool isVerifiedOnly;

  /// 회원 인증한 사용자만 url 입력 가능하도록 하는 옵션
  bool urlVerifiedUserOnly;

  /// 회원 인증한 사용자만 업로드 가능하도록 하는 옵션
  bool uploadVerifiedUserOnly;

  Map<String, bool>? users;

  /// 그룹 채팅방의 사용자 수
  /// 이 값은 /chat-joins/<uid>/<room-id> 에만 기록된다.
  int? noOfUsers;

  /// [id] It returns the chat room id.
  ///
  /// It is the node key of the chat room like the id in `/chat-rooms/{id}`.
  /// To get the message node id for both of 1:1 chat and group chat for saving message, use [messageRoomId]
  ///
  String get id => key;

  /// [path] is the path of the chat room.
  String get path => ref.path;

  bool get isSingleChat => isSingleChatRoom(id);
  bool get isGroupChat => !isSingleChat;
  bool get isOpenGroupChat => openGroupChatOrder != null;

  /// [joined] 현재 사용자가 입장해 있으면, 즉 [users] 에 현재 사용자의 UID 가 있으면, true 를 리턴한다.
  bool get joined =>
      users?.containsKey(FirebaseAuth.instance.currentUser!.uid) ?? false;

  bool get isMaster => master == myUid;

  ChatRoomModel({
    required this.ref,
    required this.key,
    this.text,
    this.url,
    this.updatedAt,
    this.createdAt,
    this.newMessage,
    this.singleChatOrder,
    this.groupChatOrder,
    this.openGroupChatOrder,
    this.name,
    this.iconUrl,
    this.photoUrl,
    this.description,
    this.master,
    this.isVerifiedOnly = false,
    this.urlVerifiedUserOnly = false,
    this.uploadVerifiedUserOnly = false,
    this.users,
    this.noOfUsers,
  });

  /// [fromSnapshot] It creates a [ChatRoomModel] from a [DataSnapshot].
  ///
  /// Example
  /// ```
  ///   final event = await RChat.roomRef(uid: data.roomId).once(DatabaseEventType.value);
  ///   final room = ChatRoomModel.fromSnapshot(event.snapshot);
  /// ```
  factory ChatRoomModel.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['key'] = snapshot.key;
    json['ref'] = snapshot.ref;
    return ChatRoomModel.fromJson(json);
  }

  factory ChatRoomModel.fromJson(Map<dynamic, dynamic> json) {
    return ChatRoomModel(
      ref: json['ref'],
      key: json['key'],
      text: json['text'] as String?,
      url: json['url'] as String?,
      updatedAt: json['updatedAt'] is int
          ? json['updatedAt']
          : int.parse(json['updatedAt'] ?? '0'),
      createdAt: json['createdAt'] is int
          ? json['createdAt']
          : int.parse(json['createdAt'] ?? '0'),
      newMessage: json['newMessage'] ?? 0,
      singleChatOrder: json['singleChatOrder'] as int?,
      groupChatOrder: json['groupChatOrder'] as int?,
      openGroupChatOrder: json['openGroupChatOrder'] as int?,
      name: json['name'] as String?,
      iconUrl: json['iconUrl'] as String?,
      photoUrl: json['photoUrl'] as String?,
      description: json['description'] as String?,
      master: json['master'] as String?,
      isVerifiedOnly: json['isVerifiedOnly'] ?? false,
      urlVerifiedUserOnly: json['urlVerifiedUserOnly'] ?? false,
      uploadVerifiedUserOnly: json['uploadVerifiedUserOnly'] ?? false,
      users:
          json['users'] == null ? null : Map<String, bool>.from(json['users']),
      noOfUsers: json['noOfUsers'] is int
          ? json['noOfUsers']
          : int.parse(json['noOfUsers'] ?? '0'),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'text': text,
      'url': url,
      'updatedAt': updatedAt,
      'newMessage': newMessage,
      'singleChatOrder': singleChatOrder,
      'groupChatOrder': groupChatOrder,
      'openGroupChatOrder': openGroupChatOrder,
      'name': name,
      'iconUrl': iconUrl,
      'photoUrl': photoUrl,
      'description': description,
      'master': master,
      'isVerifiedOnly': isVerifiedOnly,
      'urlVerifiedUserOnly': urlVerifiedUserOnly,
      'uploadVerifiedUserOnly': uploadVerifiedUserOnly,
      'users': users,
      'noOfUsers': noOfUsers,
    };
  }

  /// toString
  @override
  String toString() {
    return 'ChatRoomModel(${toJson()})';
  }

  /// Returns a [ChatRoomModel] from a group id.
  ///
  /// Note that, single chat room ref is like /chat-rooms/uidA/uidB
  ///   while group chat room ref is like /chat-rooms/groupId.
  ///
  /// This is a factory. So, you can use it for creating a chat room model object programmatically.
  factory ChatRoomModel.fromRoomdId(String id) {
    return ChatRoomModel.fromJson({
      'key': id,
      'ref': ChatService.instance.roomsRef.child(id),
    });
  }

  /// 1:1 채티에서 다른 사용자 uid 로 임시 [ChatRoomModel] 인스턴스를 만들어 리턴한다.
  ///
  /// 주의, 이 함수는 실제 DB 의 데이터를 읽지 않고, 임시로 만들므로, [key], [ref], [isGroupChat],
  /// [isOpenGroupChat] 만 지정해서 리턴한다. 실제 DB 정보가 필요하면, reload() 함수를 호출하면 된다.
  factory ChatRoomModel.fromUid(String otherUserUid) {
    return ChatRoomModel.fromJson({
      'key': singleChatRoomId(otherUserUid),
      'ref': ChatService.instance.roomRef(singleChatRoomId(otherUserUid)),
      'isGroupChat': false,
      'isOpenGroupChat': false,
    });
  }

  /// Return ChatRoomModel from a reference
  ///
  ///
  static Future<ChatRoomModel> fromReference(DatabaseReference ref) async {
    final event = await ref.once();
    if (event.snapshot.exists == false) {
      throw Issue(
        Code.chatRoomNotExists,
        'ChatRoomModel.fromReference: ${ref.path} does not exist.',
      );
    }
    return ChatRoomModel.fromSnapshot(event.snapshot);
  }

  /// Load data from database and return a [ChatRoomModel] from a group chat room id.
  ///
  /// Warning, this is for group chat only.
  ///
  static Future<ChatRoomModel> get(String id) async {
    final ref = ChatService.instance.roomsRef.child(id);
    return await fromReference(ref);
  }

  /// 현재 채팅방 정보 모델 인스턴스의 데이터를 DB 에서 다시 읽어서 리턴한다.
  ///
  /// 특히, [fromUid] 또는 [fromRoomdId] 함수를 통해서 만든 인스턴스에는 많은 정보가 빠져있는데, 실제 DB 에서
  /// 데이터를 가져와 전체 정보를 채우고자 할 때 사용하면 된다.
  ///
  /// 주의, 채팅방 노드가 생성되지 않았는데, 이 함수를 호출하면 [Code.chatRoomNotExists] 에러가 발생한다.
  Future<ChatRoomModel> reload() async {
    final room = await ChatRoomModel.get(id);

    key = room.key;
    text = room.text;
    url = room.url;
    updatedAt = room.updatedAt;
    createdAt = room.createdAt;
    newMessage = room.newMessage;
    singleChatOrder = room.singleChatOrder;
    groupChatOrder = room.groupChatOrder;
    openGroupChatOrder = room.openGroupChatOrder;
    name = room.name;
    iconUrl = room.iconUrl;
    photoUrl = room.photoUrl;
    description = room.description;
    master = room.master;
    isVerifiedOnly = room.isVerifiedOnly;
    urlVerifiedUserOnly = room.urlVerifiedUserOnly;
    uploadVerifiedUserOnly = room.uploadVerifiedUserOnly;
    users = room.users;
    noOfUsers = room.noOfUsers;

    return this;
  }

  /// Return uid list of chat room members except mine.
  ///
  /// Don't return the uid if the user unsubscribed the chat room.
  Future<List<String>> getOtherUids() async {
    return [];
  }

  /// 채팅방 생성
  ///
  /// 채팅방은
  /// - 그룹 채팅방의 경우, 사용자가 채팅 방 생성 버튼과 입력 항목을 통해서 생성할 수 있고,
  /// - 채팅 방이 존재하지 않아도, 첫번째 사용자가 채팅방에 입장 할 때, 방이 존재하지 않으면 자동으로 만든다.
  ///
  /// 주의, 입력 값 중에서
  /// - [uid] 가 들어오면 1:1 채팅방을 생성하고,
  /// - [roomId] 가 들어오면,
  ///   - [roomId] 가 1:1 채팅방 아이디이면, 1:1 채팅방을 생성하고,
  ///   - 아니면, 그룹 채팅방을 생성한다.
  /// - [uid] 와 [roomId] 둘 다 들어오지 않으면, 그룹 채팅방으로 인식하고, roomId 를 자동 생성한다.
  ///
  /// 주의, 채팅방이 존재하면 기존의 채팅방이 존재하면 몇 몇 속성이 덮어 쓰여진다.
  ///
  /// 예제 - 1:1 채팅방의 경우, 그냥 상대방의 uid 만 넣어서 호출하면 된다.
  /// ```dart
  /// await ChatRoomModel.create(uid: otherUserUid);
  /// ```
  ///
  /// It creates the chat room information and it read and returns. Don't think about the speed of reading the data.
  ///
  static Future<ChatRoomModel> create({
    String? uid,
    String? roomId,
    String? name,
    String? iconUrl,
    String? description,
    bool? isOpenGroupChat,
  }) async {
    DatabaseReference ref;
    final int minusTime = DateTime.now().millisecondsSinceEpoch * -1;
    if (uid != null) {
      // 1:1 채팅방
      ref = ChatService.instance.roomRef(singleChatRoomId(uid));
      await ref.update({
        Field.singleChatOrder: minusTime,
        Field.createdAt: ServerValue.timestamp,
        Field.updatedAt: ServerValue.timestamp,
      });
    } else if (roomId != null && isSingleChatRoom(roomId)) {
      // 1:1 채팅방 - 채팅 방 ID 가 1:1 채팅방 ID
      ref = ChatService.instance.roomRef(roomId);
      await ref.update({
        Field.singleChatOrder: minusTime,
        Field.createdAt: ServerValue.timestamp,
        Field.updatedAt: ServerValue.timestamp,
      });
    } else {
      // 그룹 채팅방을 생성할 때 추가 정보 저장
      if (roomId == null) {
        ref = ChatService.instance.roomsRef.push();
      } else {
        ref = ChatService.instance.roomsRef.child(roomId);
      }
      final myUid = FirebaseAuth.instance.currentUser!.uid;
      final data = {
        Field.name: name,
        Field.iconUrl: iconUrl,
        Code.description: description,
        Field.groupChatOrder: minusTime,
        Field.openGroupChatOrder: isOpenGroupChat == null ? null : minusTime,
        Field.createdAt: ServerValue.timestamp,
        Field.users: {myUid: true},
        Field.master: myUid,
      };
      await ref.update(data);
    }
    return fromReference(ref);
  }

  Future update({
    String? name,
    String? iconUrl,
    String? description,
    bool? isOpenGroupChat,
    String? gender,
    bool? isVerifiedOnly,
    bool? urlVerifiedUserOnly,
    bool? uploadVerifiedUserOnly,
  }) async {
    final data = {
      Field.name: name,
      if (iconUrl != null) Field.iconUrl: iconUrl,
      Code.description: description,
      Field.updatedAt: ServerValue.timestamp,
      Field.isVerifiedOnly: isVerifiedOnly,
      Field.urlVerifiedUserOnly: urlVerifiedUserOnly,
      Field.uploadVerifiedUserOnly: uploadVerifiedUserOnly,
    };
    return ref.update(data);
  }

  /// 채팅방에 남아 있는 사람이 없으면, 방을 삭제한다.
  /// If there are no remaining people in the chat room, the room is deleted.
  Future<void> deleteIfNoUsers() async {
    final room = await ChatRoomModel.get(id);

    if (room.users == null || room.users!.isEmpty) {
      await room.ref.remove();
    }
  }

  /// 사용자 초대 (또는 채팅방 입장)
  ///
  /// 이 함수는 아래와 같이 채팅방 입장 뿐만아니라 초대까지 한다.
  /// - 내가 그룹 채팅방에 처음 입장
  /// - 내가 그룹 채팅방 생성할 때, 처음 입장
  /// - 내가 다른 사용자를 초대할 때, 초대할 사용자를 입장 시킴 (즉, 초대)
  ///
  ///
  /// [uid] 는 나의 uid 일 수 있고, 다른 사용자의 uid 일 수 있다. 지정된 사용자(uid)를 현재 방에 입장시키는 것이다.
  ///
  ///
  /// 이 함수는 채팅방의 'users' 필드에 사용자 uid 를 true 로 지정하고, chat-joins 에 정보를 생성하면 된다.
  ///
  /// 1:1 채팅에서는
  /// - 로그인한 사용자가 다른 사용자와 채팅을 시작할 경우,
  /// - ChatRoom 등에서 이 함수를 호출하면 된다.
  /// - 이 함수가 최초 호출이 되는 경우 chat-rooms 의 users 에 로그인 사용자 UID 와 다른 사용자 UID 저장되지만,
  /// - 로그인을 한 사용자의 /chat-joins 만 생성되고, 다른 사용자의 /chat-joins 는 생성되지 않는다.
  /// - 로그인 한 사용자가 채팅 메시지를 하나 전송하면, 그 때서야 달느 사용자의 /chat-joins 가 생성된다.
  ///
  /// 내가 그룹 채팅방에 입장하는 경우,
  /// - 나의 UID 만 chat-rooms/users 에 저장하고
  /// - 나의 chat-joins 를 생성한다.
  ///
  /// 내가, 다른 사용자를 그룹 채팅방에 초대하는 경우,
  /// - 다른 사용자를 chat-rooms/users 에 저장하고
  /// - 다른 사용자의 chat-joins 를 생성한다.
  /// 즉, A 가 B 를 (단톡방에) 초대하면, B 의 /chat-joins 가 생성되어, 자동으로 B 의 채팅방 목록에 나온다.
  ///
  ///
  ///
  /// 이미 방에 들어가 있는 상태이면 `alreadyJoined` issue 를 생성한다.
  ///
  /// For group chat, the user uid is added to /chat-rooms/{groupChatId}/users/{[uid]: true}
  /// For 1:1 chat, create a chat room info under my chat room list only. Not the other user's.
  ///
  /// Note, it's not that harmful to set the same uid to true over again and if it happens
  /// only one time when the user enters the chat room.
  ///
  ///
  ///
  /// [forceJoin] 이 true 이면, 내가 이미 방에 들어가 있는 상태이더라도, 강제로 방에 들어간다. 특히, 채팅방을 생성 한
  /// 후에 나의 uid 가 채팅방의 users 에 들어가 있지만, /chat-joins 에 데이터가 만들어져 있지 않고, noOfUsers 와
  /// 같은 정보가 올바로 설정되어져 있지 않다. 그래서, 채팅방을 생성한 다음에는 이 옵션을 true 주고 호출하면 된다.
  ///
  Future invite(String uid, {bool forceJoin = false}) async {
    /// 채팅방 설정이 인증 회원 전용 입장 체크
    ///
    /// 인증 회원이 아니면 Issue 발생.
    /// 단, master 는 인증 안되어도 그냥 통과.
    if (master != uid && // 마스터가 아니고,
            isVerifiedOnly // 인증 회원 전용 옵션이 켜져 있는 경우,
        ) {
      bool verified = false;
      if (uid == myUid) {
        verified = my!.isVerified;
      } else {
        verified = await UserModel.getField(uid, Field.isVerified);
      }
      if (verified == false) {
        throw Issue(Code.chatRoomNotVerified);
      }
    }

    /// 내가 이미 방에 들어가 있는 상태이면 그냥 리턴
    if (forceJoin == false && users?.containsKey(uid) == true) {
      throw Issue(Code.alreadyJoined);
    }
    dog('ChatService.instance.joinRoom: Not joined, yet. Joing now ...');

    final usersRef = ref.child(Field.users);

    /// 채팅방 사용자 목록(users)에 입력된 사용자의 UID 추가
    await usersRef.child(uid).set(true);

    // 1:1 채팅이면, 채팅방의 사용자 목록에, 다른 사용자 아이디를 추가해 준다.
    if (isSingleChat) {
      if (users?.containsKey(otherUserUid) != true) {
        await usersRef.child(otherUserUid!).set(true);
      }
    } else {
      // 그룹 채팅방이면, noOfUsers 를 업데이트 한다.
      await ref.child('noOfUsers').set(users?.length ?? 1);
    }

    /// 입력된 사용자 UID 의 채팅방 목록(chat-joins)에 입장하는 채팅방 정보 저장
    ///
    final order = DateTime.now().millisecondsSinceEpoch * -1;
    final data = {
      Field.name: isGroupChat ? name : '',
      Field.groupChatOrder: isGroupChat ? order : null,
      Field.singleChatOrder: isSingleChat ? order : null,
      Field.newMessage: null,
    };

    /// 1:1 채팅방의 경우, 상대방의 이름을 저장한다.
    if (otherUserUid != null) {
      final user = await UserModel.get(otherUserUid!);
      data['name'] = user?.displayName;
    }

    // set order into -updatedAt (w/out "1")
    // it is important to know that updatedAt must not be updated
    // before this.
    data['order'] = order;
    await Ref.joinsRef.child(uid).child(id).update(data);
  }

  /// 채팅방 나가기
  ///
  /// 채팅방에서 나가는 것은 채팅방의 'users' 필드에서 나의 uid 를 삭제하고, chat-joins 에서도 해당 방을 삭제하면 된다.
  /// 1:1 채팅방이라도 방 전체 데이터를 삭제를 하지 않고, users 에 나의 uid 만 삭제한다. 1:1 채팅방에서 상대방의 채팅방
  /// 목록에는 채팅방 정보가 남아 있어야 한다.
  Future leave() async {
    await ref.child(Field.users).child(myUid!).remove();
    await Ref.join(myUid!, id).remove();
  }

  /// Return the first other user uid from the users list.
  String? get otherUserUid {
    return getOtherUserUidFromRoomId(id);
  }

  /// Returns the uids of the users who subscribed the chat room.
  List<String>? get getSubscribedUids {
    final List<String>? uids = users?.entries.fold(
      [],
      (previousValue, element) =>
          element.value ? (previousValue?..add(element.key)) : previousValue,
    );
    if (uids == null) return null;
    return uids
        .where((element) => element != FirebaseAuth.instance.currentUser!.uid)
        .toList();
  }

  /// 채팅방 알림 토글
  ///
  /// 채팅방의 'users' 필드에서 나의 uid 에 true 또는 false 를 지정하면된다.
  toggleNotifications() async {
    ref
        .child(Field.users)
        .child(myUid!)
        .set(users![myUid!] == true ? false : true);
  }
}
