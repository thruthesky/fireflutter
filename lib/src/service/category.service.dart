import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryService with FirebaseHelper {
  static CategoryService? _instance;
  static CategoryService get instance => _instance ??= CategoryService._();
  CategoryService._();

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

  showUpdateDialog(BuildContext context, Category category) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => CategoryDialog(
        category: category,
      ),
    );
  }

  showListDialog(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => const CategoryListDialog(),
    );
  }
}
