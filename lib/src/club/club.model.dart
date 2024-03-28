import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class Club {
  static final col = FirebaseFirestore.instance.collection('clubs');

  String id;
  final String uid;
  final String name;

  Club({
    required this.id,
    required this.uid,
    required this.name,
  });

  DocumentReference get ref => col.doc(id);

  factory Club.fromSnapshot(DocumentSnapshot snapshot) {
    return Club.fromMap(snapshot.data() as Map, snapshot.id);
  }

  factory Club.fromMap(Map<dynamic, dynamic> map, String id) {
    return Club(
      id: id,
      uid: map['uid'],
      name: map['name'],
    );
  }

  /// 클럽 생성을 위한, 데이터 맵을 만든다.
  static Map<String, dynamic> toCreate({
    required String uid,
    required String name,
  }) {
    return {
      'uid': uid,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// 모임 만들기
  ///
  /// 1. 채팅방 생성
  /// 2. 게시판 생성
  /// 3. 갤러리 게시판 생성
  static Future<DocumentReference> create({
    required String name,
  }) async {
    if (name.trim().isEmpty) {
      throw FireFlutterException('club-create/name-empty', 'Input name.');
    }

    final ref = await col.add(
      Club.toCreate(
        uid: myUid!,
        name: name,
      ),
    );

    final room = await ChatRoom.create(
      name: name,
      roomId: ref.id,
      isOpenGroupChat: false,
    );

    final chat = ChatModel(room: room);
    await chat.join(forceJoin: true);

    return ref;
  }

  /// 모임 탈퇴
  ///
  /// 이 때, 채팅방도 같이 탈퇴를 해야 한다.
  leave() {
    //
    // 채팅방 탈퇴
  }
}
