import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'viewer.g.dart';

@JsonSerializable()
class Viewer {
  Viewer({
    required this.seenBy,
    this.type,
    this.uid = '',
    dynamic lastViewedAt,
    required this.year,
    required this.month,
    required this.day,
  }) : lastViewedAt = (lastViewedAt is Timestamp)
            ? lastViewedAt.toDate()
            : DateTime.now();
  final String seenBy;
  final String? type;

  final String uid;

  /// 사용자 문서가 생성된 시간. 항상 존재 해야 함. Firestore 서버 시간
  @FirebaseDateTimeConverter()
  @JsonKey(includeFromJson: false, includeToJson: true)
  final DateTime lastViewedAt;

  final int year;
  final int month;
  final int day;

  factory Viewer.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Viewer.fromJson(documentSnapshot.data() as Map<String, dynamic>);
  }

  factory Viewer.fromJson(Map<String, dynamic> json) => _$ViewerFromJson(json);
  Map<String, dynamic> toJson() => _$ViewerToJson(this);
}
