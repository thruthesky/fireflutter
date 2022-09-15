import 'package:cloud_firestore/cloud_firestore.dart';

class PointHistoryModel {
  int point;
  Timestamp createdAt;
  String eventName;

  PointHistoryModel({
    required this.point,
    required this.createdAt,
    required this.eventName,
  });

  factory PointHistoryModel.fromJson(Map<String, dynamic> data) {
    return PointHistoryModel(
      point: data['point'],
      createdAt: data['createdAt'],
      eventName: data['eventName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'point': point,
      'createdAt': createdAt,
      'eventName': eventName,
    };
  }

  @override
  String toString() {
    return "PostHistoryModel(${toJson()})";
  }
}
