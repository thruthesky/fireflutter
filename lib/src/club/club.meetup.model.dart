import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class ClubMeetup {
  static CollectionReference col(String clubId) => FirebaseFirestore.instance
      .collection('clubs')
      .doc(clubId)
      .collection('club-meetups');

  final String id;
  final String uid;
  final List<String> users;
  final String title;
  final String description;
  final String photoUrl;

  ClubMeetup({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.photoUrl,
    required this.users,
  });

  factory ClubMeetup.fromSnapshot(DocumentSnapshot snapshot) {
    return ClubMeetup.fromMap(snapshot.data() as Map, snapshot.id);
  }

  factory ClubMeetup.fromMap(Map<dynamic, dynamic> map, String id) {
    return ClubMeetup(
      id: id,
      uid: map['uid'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photoUrl: map['photoUrl'],
      users: List<String>.from((map['users'] ?? [])),
    );
  }

  /// 오프라인 모임 생성을 위한, 데이터 맵을 만든다.
  static Map<String, dynamic> toCreate({
    required String clubId,
    required String title,
  }) {
    return {
      'uid': myUid!,
      'users': [],
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// 오프라인 모임 일정 만들기
  ///
  static Future<ClubMeetup> create({
    required String clubId,
    required String title,
  }) async {
    if (title.trim().isEmpty) {
      throw FireFlutterException(
          'club-meetup-create/title-empty', 'Input title.');
    }

    final ref = await col(clubId).add(
      ClubMeetup.toCreate(
        clubId: clubId,
        title: title,
      ),
    );

    final meetup = await get(ref);

    return meetup;
  }

  static Future<ClubMeetup> get(DocumentReference ref) async {
    final snapshot = await ref.get();
    return ClubMeetup.fromSnapshot(snapshot);
  }
}
