import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final String uid;
  final String activity;
  final String name;
  final String? target;
  final String? targetId;

  Activity({
    required this.activity,
    required this.uid,
    required this.name,
    this.target,
    this.targetId,
  });
}
