import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class Meetup {
  static CollectionReference col =
      FirebaseFirestore.instance.collection('meetups');

  DocumentReference get ref => Meetup.col.doc(id);

  final String id;
  final String? clubId;
  final String uid;
  final List<String> users;
  final String title;
  final String description;
  final String? photoUrl;
  final DateTime? meetAt;

  Meetup({
    required this.id,
    required this.clubId,
    required this.uid,
    required this.title,
    required this.description,
    required this.photoUrl,
    required this.users,
    required this.meetAt,
  });

  bool get joined => users.contains(myUid);

  factory Meetup.fromSnapshot(DocumentSnapshot snapshot) {
    return Meetup.fromMap(snapshot.data() as Map, snapshot.id);
  }

  factory Meetup.fromMap(Map<dynamic, dynamic> map, String id) {
    return Meetup(
      id: id,
      clubId: map['clubId'],
      uid: map['uid'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photoUrl: map['photoUrl'],
      users: List<String>.from((map['users'] ?? [])),
      meetAt: map['meetAt'] is Timestamp
          ? (map['meetAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Generate toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clubId': clubId,
      'uid': uid,
      'title': title,
      'description': description,
      'photoUrl': photoUrl,
      'users': users,
      'meetAt': meetAt,
    };
  }

  /// 오프라인 모임 생성을 위한, 데이터 맵을 만든다.
  static Map<String, dynamic> toCreate({
    String? clubId,
    required String title,
  }) {
    return {
      if (clubId != null) 'clubId': clubId,
      'uid': myUid!,
      'users': [],
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return "Meetup{${toMap()}}";
  }

  /// 오프라인 모임 일정 만들기
  ///
  static Future<Meetup> create({
    String? clubId,
    required String title,
  }) async {
    if (title.trim().isEmpty) {
      throw FireFlutterException(
        'club-meetup-create/title-empty',
        'Input title.',
      );
    }

    final ref = await col.add(
      Meetup.toCreate(
        clubId: clubId,
        title: title,
      ),
    );

    final meetup = await get(ref);

    return meetup;
  }

  static Future<Meetup> get(DocumentReference ref) async {
    final snapshot = await ref.get();
    return Meetup.fromSnapshot(snapshot);
  }

  /// Update club
  ///
  /// [photoUrl] is optional. After uploading photo into Storage, set the photo url using this parameter.
  /// And [hasPhoto] is set to true if [photoUrl] is not null.
  /// If [photoUrl] is null, it does not update [photoUrl], nor [hasPhoto]
  /// ! If [photoUrl] is empty string, then, [photoUrl] is deleted from document and [hasPhoto] is set to false.
  ///
  ///
  Future<void> update({
    String? title,
    String? description,
    String? photoUrl,
    bool? hasPhoto,
    DateTime? meetAt,
  }) async {
    // 모임 이름이 들어오는 경우, 빈 문자열이면 에러
    if (title != null && title.trim().isEmpty) {
      throw FireFlutterException(
          'club-meetup-update/title-empty', 'Input title.');
    }

    final Map<String, dynamic> data = {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (meetAt != null) 'meetAt': meetAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    /// Photo
    if (photoUrl == null) {
      /// do nothing
    } else if (photoUrl == '') {
      data['photoUrl'] = FieldValue.delete();
      data['hasPhoto'] = false;
    } else {
      data['photoUrl'] = photoUrl;
      data['hasPhoto'] = true;
    }

    await ref.update(data);
  }

  Future<void> join() async {
    if (users.contains(myUid)) {
      throw FireFlutterException(
        Code.meetupAlreadyJoined,
        'You already joined this meetup.',
      );
    }

    await ref.update({
      'users': FieldValue.arrayUnion([myUid]),
    });

    users.add(myUid!);
  }

  Future<void> leave() async {
    if (users.contains(myUid) == false) {
      throw FireFlutterException(
        Code.meetupNotJoined,
        'You have not joined this meetup, yet.',
      );
    }

    await ref.update({
      'users': FieldValue.arrayRemove([myUid]),
    });

    users.remove(myUid);
  }
}
