import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class CategoryService with ForumMixin {
  static CategoryService? _instance;
  static CategoryService get instance {
    _instance ??= CategoryService();
    return _instance!;
  }

  List<CategoryModel> categories = [];

  /// see readme
  Future<List<CategoryModel>> getCategories(
      {bool hideHiddenCategory: false}) async {
    if (categories.length == 0) {
      categories = await loadCategories();
    }
    if (hideHiddenCategory) {
      return categories.where((cat) => cat.order != -1).toList();
    } else {
      return categories;
    }
  }

  /// See readme
  Future<List<CategoryModel>> loadCategories({
    String? categoryGroup,
  }) async {
    Query q = categoryCol;
    if (categoryGroup != null) {
      q = q.where('categoryGroup', isEqualTo: categoryGroup);
    }
    final querySnapshot = await q.orderBy('order', descending: true).get();

    if (querySnapshot.size == 0) return [];

    final List<CategoryModel> _categories = [];

    for (DocumentSnapshot doc in querySnapshot.docs) {
      _categories.add(CategoryModel.fromJson(doc.data(), doc.id));
    }
    return _categories;
  }
}
