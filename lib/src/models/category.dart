import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/src/services.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String createdBy;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory Category.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Category.fromMap(map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory Category.fromMap({required Map<String, dynamic> map, required id}) {
    return Category(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }

  /// Creates a category and returns the category.
  ///
  static Future<Category> create({
    required String name,
    String? description,
  }) async {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    final Map<String, dynamic> categoryData = {
      'name': name,
      if (description != null) 'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': myUid,
    };
    final categoryId = CategoryService.instance.categoryCol.doc().id;
    await CategoryService.instance.categoryCol.doc(categoryId).set(categoryData);
    categoryData['createdAt'] = Timestamp.now();
    categoryData['updatedAt'] = Timestamp.now();
    return Category.fromMap(map: categoryData, id: categoryId);
  }

  @override
  String toString() =>
      'Category(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy)';
}
