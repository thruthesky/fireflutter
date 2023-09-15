import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'viewer.g.dart';

@JsonSerializable()
class Viewer with FirebaseHelper {
  Viewer({
    required this.seenBy,
    this.type,
    this.uid = '',
    this.postId = '',
    dynamic lastViewedAt,
    required this.year,
    required this.month,
    required this.day,
  }) : lastViewedAt = (lastViewedAt is Timestamp) ? lastViewedAt.toDate() : DateTime.now();
  final String seenBy;
  final String? type;

  @override
  final String uid;
  final String postId;

  /// 사용자 문서가 생성된 시간. 항상 존재 해야 함. Firestore 서버 시간
  @FirebaseDateTimeConverter()
  @JsonKey(includeFromJson: false, includeToJson: true)
  final DateTime lastViewedAt;

  final int year;
  final int month;
  final int day;
}
