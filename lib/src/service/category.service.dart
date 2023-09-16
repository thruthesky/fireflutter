import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryService {
  static CategoryService? _instance;
  static CategoryService get instance => _instance ??= CategoryService._();
  CategoryService._();

  /// [categoriesOnCreate] is a list of categories that will be shown on the
  /// post create form. You can display and limit the categories that a user
  /// can create a post under. To not show any categories, set this to an empty
  /// map which is the default. When you design your app, you may open a post
  /// create from without specifying the default category.
  ///
  Map<String, String> categoriesOnCreate = {};

  init({
    Map<String, String> categoriesOnCreate = const {},
  }) {
    this.categoriesOnCreate = categoriesOnCreate;
  }

  Future<Category?> get(String categoryId) {
    return Category.get(categoryId);
  }

  /// Show Create Category Dialog
  ///
  /// A dialog to create a category.
  /// It will ask for a name of a category.
  showCreateDialog(
    BuildContext context, {
    required void Function(Category category) success,
    void Function()? cancel,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => CategoryCreateScreen(
        success: success,
        cancel: cancel,
      ),
    );
  }

  @Deprecated('Use Category.create() instead')
  create({required String categoryId, required String categoryName}) {
    return Category.create(
      categoryId: categoryId,
      name: categoryName,
    );
  }

  showUpdateDialog(BuildContext context, String categoryId) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => CategoryEditScreen(
        categoryId: categoryId,
      ),
    );
  }

  /// Displays a full screen dialog that will show a list of all categories.
  /// By default, upon tapping a category, it will list all the posts.
  /// Use [onTapCategory] to replace the default action upon tapping.
  showListDialog(BuildContext context, {Function(Category category)? onTapCategory}) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => AdminCategoryListScreen(
        onTapCategory: (category) {
          if (onTapCategory != null) {
            onTapCategory.call(category);
          } else {
            PostService.instance.showPostListDialog(context, category.id);
          }
        },
      ),
    );
  }
}
