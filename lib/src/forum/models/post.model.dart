import 'package:firebase_database/firebase_database.dart';

class PostModel {
  String id;
  String title;
  String content;
  int orderNo;
  int createdAt;
  int updatedAt;
  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.orderNo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromQuerySnapshot(DataSnapshot dataSnapshot) {
    if (dataSnapshot.exists == false || dataSnapshot.value == null) {
      return PostModel(
        id: '',
        title: '',
        content: '',
        orderNo: 0,
        createdAt: 0,
        updatedAt: 0,
      );
    }
    final map = Map<String, dynamic>.from(dataSnapshot.value as dynamic);
    final key = map.keys.first;
    return PostModel.fromJson(map[key], key);
  }

  /// Create a new PostModel instance from a DataSnapshot
  ///
  /// The snapshot must have a single document inside.
  factory PostModel.fromSnapshot(DataSnapshot snapshot) {
    return PostModel.fromJson(Map<String, dynamic>.from(snapshot.value as dynamic), snapshot.key ?? '');
  }
  factory PostModel.fromJson(Map<dynamic, dynamic> json, String id) {
    return PostModel(
      id: id,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      orderNo: json['orderNo'] ?? 0,
      createdAt: json['createdAt'] ?? 0,
      updatedAt: json['updatedAt'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'PostModel(id: $id, title: $title, content: $content, orderNo: $orderNo, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
