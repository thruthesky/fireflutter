import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryService {
  static CategoryService? _instance;
  static CategoryService get instance => _instance ??= CategoryService._();
  CategoryService._();

  CollectionReference get categoryCol => FirebaseFirestore.instance.collection('categories');
  DocumentReference categoryDoc(String categoryId) => categoryCol.doc(categoryId);

  /// TODO: Support official localization.
  Map<String, String> texts = {};

  /// Show Create Category Dialog
  ///
  /// A dialog to create a category.
  /// It will ask for a name of a category.
  showCreateCategoryDialog(
    BuildContext context, {
    required void Function(Category category) success,
    required void Function() cancel,
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
}
