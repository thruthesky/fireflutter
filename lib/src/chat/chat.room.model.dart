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
  String? photoUrl;
  String? description;
  String? master;

  /// 회원 인증한 사용자만 입장 가능하도록 하는 옵션
  bool isVerifiedOnly;

  /// 회원 인증한 사용자만 url 입력 가능하도록 하는 옵션
  bool urlVerified;

  /// 회원 인증한 사용자만 업로드 가능하도록 하는 옵션
  bool uploadVerified;

  Map<String, bool>? users;

  /// 그룹 채팅방의 사용자 수
  /// 이 값은 /chat-joins/<uid>/<room-id> 에만 기록된다.
  int? noOfUsers;
  int? order;

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
    this.photoUrl,
    this.description,
    this.master,
    this.isVerifiedOnly = false,
    this.urlVerified = false,
    this.uploadVerified = false,
    this.users,
    this.noOfUsers,
    this.order,
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
      updatedAt: json['updatedAt'] is int ? json['updatedAt'] : int.parse(json['updatedAt'] ?? '0'),
      createdAt: json['createdAt'] is int ? json['createdAt'] : int.parse(json['createdAt'] ?? '0'),
      newMessage: json['newMessage'] ?? 0,
      singleChatOrder: json['singleChatOrder'] as int?,
      groupChatOrder: json['groupChatOrder'] as int?,
      openGroupChatOrder: json['openGroupChatOrder'] as int?,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      description: json['description'] as String?,
      master: json['master'] as String?,
      isVerifiedOnly: json['isVerifiedOnly'] ?? false,
      urlVerified: json['urlVerified'] ?? false,
      uploadVerified: json['uploadVerified'] ?? false,
      users: json['users'] == null ? null : Map<String, bool>.from(json['users']),
      noOfUsers: json['noOfUsers'] is int ? json['noOfUsers'] : int.parse(json['noOfUsers'] ?? '0'),
      order: json['order'] is int ? json['order'] : int.parse(json['order'] ?? '0'),
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
      'photoUrl': photoUrl,
      'description': description,
      'master': master,
      'isVerifiedOnly': isVerifiedOnly,
      'urlVerified': urlVerified,
      'uploadVerified': uploadVerified,
      'users': users,
      'noOfUsers': noOfUsers,
      'order': order,
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

  // /// Returns a [ChatRoomModel] from a single chat room id.
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
      throw Exception('ChatRoomModel.fromReference: ${ref.path} does not exist.');
    }
    return ChatRoomModel.fromSnapshot(event.snapshot);
  }

  /// Load data from database and return a [ChatRoomModel] from a group chat room id.
  ///
  /// Warning, this is for group chat only.
  ///
  static Future<ChatRoomModel> get(String id) {
    final ref = ChatService.instance.roomsRef.child(id);
    return fromReference(ref);
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
  /// It creates the chat room information and it read and returns. Don't think about the speed of reading the data.
  ///
  static Future<ChatRoomModel> create({
    String? uid,
    String? roomId,
    String? name,
    String? description,
    bool? isOpenGroupChat,
  }) async {
    DatabaseReference ref;
    final int minusTime = DateTime.now().millisecondsSinceEpoch * -1;
    if (uid != null) {
      ref = ChatService.instance.roomRef(singleChatRoomId(uid));
      await ref.update({
        Def.singleChatOrder: minusTime,
        Def.createdAt: ServerValue.timestamp,
        Def.updatedAt: ServerValue.timestamp,
      });
    } else if (roomId != null && isSingleChatRoom(roomId)) {
      // 채팅 방 ID 가 1:1 채팅방?
      ref = ChatService.instance.roomRef(roomId);
      await ref.update({
        Def.singleChatOrder: minusTime,
        Def.createdAt: ServerValue.timestamp,
        Def.updatedAt: ServerValue.timestamp,
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
        Def.name: name,
        Def.description: description,
        Def.groupChatOrder: minusTime,
        Def.openGroupChatOrder: isOpenGroupChat == null ? null : minusTime,
        Def.createdAt: ServerValue.timestamp,
        Def.users: {myUid: true},
        Def.master: myUid,
      };
      await ref.update(data);
    }
    return fromReference(ref);
  }

  Future update({
    String? name,
    String? description,
    bool? isOpenGroupChat,
    String? gender,
    bool? isVerifiedOnly,
    bool? urlVerified,
    bool? uploadVerified,
  }) async {
    final data = {
      Def.name: name,
      Def.description: description,
      Def.updatedAt: ServerValue.timestamp,
      Def.isVerifiedOnly: isVerifiedOnly,
      Def.urlVerified: urlVerified,
      Def.uploadVerified: uploadVerified,
    };
    return ref.update(data);
  }

  /// 채팅방에 남아 있는 사람이 없으면, 방을 삭제한다.
  Future<void> deleteIfNoUsers() async {
    final room = await ChatRoomModel.get(id);

    if (room.users == null || room.users!.isEmpty) {
      await room.ref.remove();
    }
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
    return uids.where((element) => element != FirebaseAuth.instance.currentUser!.uid).toList();
  }
}
