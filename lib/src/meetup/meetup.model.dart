import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Meetup {
  static final col = FirebaseFirestore.instance.collection('meetups');

  String id;
  final String uid;
  final String master;
  final String name;
  final String description;
  final String? photoUrl;
  final List<String> users;
  final String reminder;

  final int? recommendOrder;

  final List<String> blockedUsers;

  bool isVerifiedOnly;

  Meetup({
    required this.id,
    required this.uid,
    required this.master,
    required this.name,
    required this.description,
    this.photoUrl,
    required this.users,
    required this.reminder,
    this.recommendOrder,
    required this.blockedUsers,
    this.isVerifiedOnly = false,
  });

  DocumentReference get ref => col.doc(id);

  bool get joined => users.contains(myUid);
  bool get isMaster => master == myUid;
  bool get blocked => blockedUsers.contains(myUid);

  factory Meetup.fromSnapshot(DocumentSnapshot snapshot) {
    return Meetup.fromMap(snapshot.data() as Map, snapshot.id);
  }

  factory Meetup.fromMap(Map<dynamic, dynamic> map, String id) {
    return Meetup(
      id: id,
      uid: map[Field.uid],
      master: map[Field.master] ??
          map[Field.uid], // 초반 개발에서 에러 방지. 나중에 map[uid] 는 없애도 됨.
      name: map[Field.name] ?? '',
      description: map[Field.description] ?? '',
      photoUrl: map[Field.photoUrl],
      users: List<String>.from((map[Field.users] ?? [])),
      reminder: map[Field.reminder] ?? '',
      recommendOrder: map[Field.recommendOrder],
      blockedUsers: List<String>.from((map[Field.blockedUsers] ?? [])),
      isVerifiedOnly: map[Field.isVerifiedOnly] ?? false,
    );
  }

  @override
  String toString() {
    return 'Meetup{id: $id, uid: $uid, master: $master, name: $name, description: $description, photoUrl: $photoUrl, users: $users, reminder: $reminder, recommendOrder: $recommendOrder, blockedUsers: $blockedUsers, isVerifiedOnly: $isVerifiedOnly}';
  }

  /// 클럽 생성을 위한, 데이터 맵을 만든다.
  static Map<String, dynamic> toCreate({
    required String name,
  }) {
    return {
      Field.uid: myUid!,
      Field.master: myUid!,
      Field.users: [myUid!],
      Field.name: name,
      Field.createdAt: FieldValue.serverTimestamp(),
    };
  }

  static Future<Meetup> get({String? id, DocumentReference? ref}) async {
    if (id == null && ref == null) {
      throw FireFlutterException('meetup-get/id-null', 'Input id or ref.');
    }
    ref ??= col.doc(id);
    final snapshot = await ref.get();
    return Meetup.fromSnapshot(snapshot);
  }

  /// 모임 만들기
  ///
  /// 1. 채팅방 생성
  /// 2. 게시판 생성
  /// 3. 갤러리 게시판 생성
  ///
  /// 생성된 Meetup 객체를 리턴한다.
  static Future<Meetup> create({
    required String name,
  }) async {
    if (name.trim().isEmpty) {
      throw FireFlutterException('meetup-create/name-empty', 'Input name.');
    }

    final ref = await col.add(
      Meetup.toCreate(
        name: name,
      ),
    );

    final meetup = await Meetup.get(ref: ref);

    final room = await ChatRoom.create(
      name: name,
      roomId: meetup.id,
      isOpenGroupChat: false,
    );

    final chat = ChatModel(room: room);
    await chat.room.join(forceJoin: true);

    return meetup;
  }

  /// Update meetup
  ///
  /// [photoUrl] is optional. After uploading photo into Storage, set the photo url using this parameter.
  /// And [hasPhoto] is set to true if [photoUrl] is not null.
  /// If [photoUrl] is null, it does not update [photoUrl], nor [hasPhoto]
  /// ! If [photoUrl] is empty string, then, [photoUrl] is deleted from document and [hasPhoto] is set to false.
  ///
  ///
  Future<void> update({
    String? name,
    String? description,
    String? photoUrl,
    bool? hasPhoto,
    String? reminder,
    int? recommendOrder,
    bool? isVerifiedOnly,
  }) async {
    // 모임 이름이 들어오는 경우, 빈 문자열이면 에러
    if (name != null && name.trim().isEmpty) {
      throw FireFlutterException('meetup-update/name-empty', 'Input name.');
    }

    final Map<String, dynamic> data = {
      if (name != null) Field.name: name,
      if (description != null) Field.description: description,
      Field.updatedAt: FieldValue.serverTimestamp(),
      if (reminder != null) Field.reminder: reminder,
    };

    /// Photo
    if (photoUrl == null) {
      /// do nothing
    } else if (photoUrl == '') {
      data[Field.photoUrl] = FieldValue.delete();
      data[Field.hasPhoto] = false;
    } else {
      data[Field.photoUrl] = photoUrl;
      data[Field.hasPhoto] = true;
    }

    if (recommendOrder != null) {
      data[Field.recommendOrder] =
          recommendOrder > 0 ? recommendOrder : FieldValue.delete();
    }

    if (isVerifiedOnly != null) {
      data[Field.isVerifiedOnly] = isVerifiedOnly;
    }

    await ref.update(data);
  }

  /// 클럽 가입
  ///
  /// 클럽 가입 할 때, 채팅방에 따로 입장 할 필요 없이, 최초 채팅방 입장시 자동으로 chat-rooms/{users}, chat-join 등이 설정된다.
  /// 하지만, 사용자가 채팅방에 입장을 하지 않을 수 있으니, 미리 채팅방 입장을 해 준다.
  join() async {
    if (isVerifiedOnly && my!.isVerified == false) {
      throw FireFlutterException(
          Code.meetupNotVerified, 'This meetup is for verified users only.');
    }

    await ref.update({
      Field.users: FieldValue.arrayUnion([myUid]),
    });
    await ChatRoom.fromRoomdId(id).join(uid: myUid!, forceJoin: true);
  }

  /// 클럽 탈퇴
  ///
  /// 이 때, 채팅방도 같이 탈퇴를 해야 한다.
  leave() async {
    await ref.update({
      Field.users: FieldValue.arrayRemove([myUid]),
    });
    await ChatRoom.fromRoomdId(id).leave();
  }

  /// 클럽 삭제
  ///
  /// 현재는 채팅방이나 게시글을 삭제하지 않고, 그냥 클럽 문서만 삭제를 해 버린다.
  Future<bool> delete({required BuildContext context}) async {
    final re = await confirm(
      context: context,
      title: T.deleteMeetup.tr,
      message: T.deleteMeetupMessage.tr,
    );
    if (re != true) return false;
    await ref.delete();
    return true;
  }

  Future<void> unblockUser({
    required BuildContext context,
    required String otherUserUid,
    bool ask = false,
    bool notify = true,
  }) async {
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: Code.unblock,
          data: {
            'otherUserUid': otherUserUid,
          });
      if (re != true) return;
    }

    if (ask) {
      bool? re = await confirm(
        context: context,
        title: T.meetupUnblockUser.tr,
        message: T.meetupUnblockConfirmMessage.tr,
      );
      if (re != true) return;
    }

    await ref.update({
      Field.users: FieldValue.arrayUnion([otherUserUid]),
      Field.blockedUsers: FieldValue.arrayRemove([otherUserUid]),
    });

    /// 차단 후 화면에 알림
    if (notify && context.mounted) {
      toast(
        context: context,
        title: T.unblocked.tr,
        message: T.unblockedMessage.tr,
      );
    }
  }

  Future<void> blockUser({
    required BuildContext context,
    required String otherUserUid,
    bool ask = false,
    bool notify = true,
  }) async {
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: Code.block,
          data: {
            'otherUserUid': otherUserUid,
          });
      if (re != true) return;
    }

    if (otherUserUid == myUid) {
      toast(context: context, message: T.cannotBlockYourself.tr);
      return;
    }

    if (ask) {
      bool? re = await confirm(
        context: context,
        title: T.meetupBlockUser.tr,
        message: T.meetupBlockConfirmMessage.tr,
      );
      if (re != true) return;
    }

    await ref.update({
      Field.blockedUsers: FieldValue.arrayUnion([otherUserUid]),
      Field.users: FieldValue.arrayRemove([otherUserUid]),
    });

    /// 차단 후 화면에 알림
    if (notify && context.mounted) {
      toast(
        context: context,
        title: T.blocked.tr,
        message: T.blockedMessage.tr,
      );
    }
  }
}
