import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class Category with ForumMixin {
  Category({
    required this.id,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.order,
    required this.point,
    required this.categoryGroup,
  });

  String id;
  String title;
  String description;
  String backgroundColor;
  String foregroundColor;
  int order;
  int point;
  String categoryGroup;

  factory Category.emtpy() => Category.fromJson({}, '');
  factory Category.fromJson(dynamic data, String id) {
    return Category(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      backgroundColor: data['backgroundColor'] ?? '',
      foregroundColor: data['foregroundColor'] ?? '',
      order: toInt(data['order']),
      point: toInt(data['point']),
      categoryGroup: data['categoryGroup'] ?? '',
    );
  }

  /// Return an int from dynamic.
  ///
  /// Use this to transform a string into int.
  ///
  /// ! 이 함수를 functions.dart 의 글로벌 함수로 바꿀 것. 이름 충돌이 나면, 클래스로 보관 할 것.
  static int toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) {
      return v;
    } else if (v is double) {
      return v.floor();
    } else {
      return int.parse(v);
    }
  }

  /// category create
  static Future<void> create({
    required String category,
    required String title,
    required String description,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'order': 0,
      'point': 0,
      'categoryGroup': '',
    };
    final categoryCol = FirebaseFirestore.instance.collection('categories');
    final doc = await categoryCol.doc(category).get();
    if (doc.exists) throw 'Category already exists';
    return categoryCol.doc(category).set(data);
  }

  /// Update category
  ///
  /// ```dart
  /// final cat = Category.fromJson({}, 'job');
  /// cat.update('foregroundColor', 'color').catchError(service.error);
  /// ```
  Future<void> update(String field, dynamic value) {
    return categoryDoc(id).update({field: value});
  }

  Future<void> updateBackgroundColor(String value) {
    return update('backgroundColor', value);
  }

  Future<void> updateForegroundColor(String value) {
    return update('foregroundColor', value);
  }

  Future<void> delete() {
    return categoryDoc(id).delete();
  }
}
