import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class CategoryModel with ForumMixin {
  CategoryModel({
    this.id = '',
    this.title = '',
    this.description = '',
    this.order = 0,
    this.point = 0,
    this.group = '',
  });

  String id;
  String title;
  String description;
  int order;
  int point;
  String group;

  factory CategoryModel.emtpy() => CategoryModel.fromJson({}, '');

  factory CategoryModel.fromSnapshot(DocumentSnapshot doc) {
    return CategoryModel.fromJson(doc.data(), doc.id);
  }

  factory CategoryModel.fromJson(dynamic data, String id) {
    return CategoryModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      order: toInt(data['order']),
      point: toInt(data['point']),
      group: data['group'] ?? '',
    );
  }

  Map<String, dynamic> get map {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'point': point,
      'group': group,
    };
  }

  @override
  toString() {
    return 'CategoryModel($map)';
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
  Future<void> create({
    required String category,
    String title = '',
    String description = '',
    int point = 0,
    int order = 0,
    String group = '',
  }) async {
    if (category == '') throw ERROR_CATEGORY_IS_EMPTY_ON_CATEGORY_CREATE;
    final data = {
      'title': title,
      'description': description,
      'order': order,
      'point': point,
      'group': group,
      'createdAt': serverTimestamp,
    };
    final categoryCol = FirebaseFirestore.instance.collection('categories');
    final doc = await categoryCol.doc(category).get();
    if (doc.exists) throw ERROR_CATEGORY_EXISTS_ON_CATEGORY_CREATE;
    return categoryCol.doc(category).set(data);
  }

  /// Update category
  ///
  /// ```dart
  /// final cat = CategoryModel.fromJson({}, 'job');
  /// ```
  Future<void> update(Map<String, Object?> data) {
    return categoryDoc(id).update(data);
  }

  Future<void> delete() {
    return categoryDoc(id).delete();
  }
}
