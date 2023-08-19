import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryService with FireFlutter {
  static CategoryService? _instance;
  static CategoryService get instance => _instance ??= CategoryService._();
  CategoryService._();

  /// Show Create Category Dialog
  ///
  /// A dialog to create a category.
  /// It will ask for a name of a category.
  showCreateCategoryDialog(
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

  createCategory({required String categoryName}) {
    return Category.create(
      name: categoryName,
    );
  }

  /// Update Category
  updateCategory(String categoryId, Map<String, dynamic> categoryUpdates) async {
    await categoryDoc(categoryId).update({
      'name': categoryUpdates['name'],
      'description': categoryUpdates['description'],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  showCategoryDialog(BuildContext context, Category category) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => CategoryDialog(
        category: category,
      ),
    );
  }
}
