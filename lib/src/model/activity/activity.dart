import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final String action;
  final String type;
  final String uid;
  final String name;
  final String? postId;
  final String? commentId;
  final String? roomId;
  final String? title;
  final String? otherUid;
  final String? otherDisplayName;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  Activity({
    required this.action,
    required this.type,
    required this.uid,
    required this.name,
    required this.createdAt,
    this.postId,
    this.commentId,
    this.roomId,
    this.title,
    this.otherUid,
    this.otherDisplayName,
  });

  /// dont use directly,
  /// use [ActivityService.instance.log(...)] instead
  static Future<void> create({
    required String action,
    required String type,
    String? uid,
    String? name,
    String? postId,
    String? commentId,
    String? roomId,
    String? title,
    String? otherUid,
    String? otherDisplayName,
  }) async {
    final Map<String, dynamic> data = {
      'action': action,
      'type': type, // 'post', 'comment', 'user', 'chat'
      'uid': uid ?? myUid,
      'name': name ?? my!.name,
      if (postId != null) 'postId': postId,
      if (commentId != null) 'commentId': commentId,
      if (roomId != null) 'roomId': roomId,
      if (title != null) 'title': title,
      if (otherUid != null) 'otherUid': otherUid,
      if (otherDisplayName != null) 'otherDisplayName': otherDisplayName,
      'createdAt': ServerValue.timestamp,
    };
    final re = activityLogRef.push();
    await re.set(data);
    final act = await activityLogRef.child(re.key!).get();
    re.update({'reverseCreatedAt': (act.value as dynamic)['createdAt'] * -1});
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return _$ActivityFromJson(json);
  }

  factory Activity.fromDocumentSnapshot(DataSnapshot snapshot) {
    return Activity.fromJson(
      {
        ...(snapshot.value as Map<dynamic, dynamic>),
        ...{'id': snapshot.key},
      },
    );
  }
  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  @override
  String toString() => 'Activity:: (${toJson()})';
}
