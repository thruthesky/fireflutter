import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class CategoryService with ForumMixin {
  static CategoryService? _instance;
  static CategoryService get instance {
    _instance ??= CategoryService();
    return _instance!;
  }

  List<CategoryModel> categories = [];

  /// Returns all categories.
  ///
  /// It does memory cache.
  ///
  /// Note if categoris are not fetched from firestore, then it will fetch and
  /// return [categories].
  /// Note if categories are already fetched, then it will return memory cached
  /// categories, instead of fetcing again.
  ///
  /// If [hideHiddenCategory] is set to true, then it will not return categories whose order is -1.
  ///
  /// Note that, this is async call. So, it should be used with `setState`
  /// ```dart
  /// ```
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

  /// Loads categories and return them as in List of Category model.
  ///
  /// You can filter some categories by [categoryGroup].
  ///
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
