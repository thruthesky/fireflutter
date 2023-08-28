import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryService with FirebaseHelper {
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
      builder: (_) => CategoryCreateDialog(
        success: success,
        cancel: cancel,
      ),
    );
  }

  create({required String categoryId, required String categoryName}) {
    return Category.create(
      categoryId: categoryId,
      name: categoryName,
    );
  }

  /// Update Category
  update(String categoryId, Map<String, dynamic> categoryUpdates) async {
    await categoryDoc(categoryId).update({
      'name': categoryUpdates['name'],
      'description': categoryUpdates['description'],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  showUpdateDialog(BuildContext context, String categoryId) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => CategoryDialog(
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
      pageBuilder: (context, _, __) => CategoryListDialog(
        onTapCategory: (category) {
          if (onTapCategory != null) {
            onTapCategory.call(category);
          } else {
            PostService.instance.showPostListDialog(context, category);
          }
        },
      ),
    );
  }
}
