import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/src/services.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final Timestamp? createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory Category.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Category.fromMap(map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory Category.fromMap({required Map<String, dynamic> map, required id}) {
    return Category(
      id: id,
      name: map['name'],
      description: map['description'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
    };
  }

  /// Creates a category and returns the category.
  ///
  static Future<Category> create({
    required String name,
  }) async {
    String myUid = FirebaseAuth.instance.currentUser!.uid; // TODO addedBy
    final categoryData = {
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    };
    final categoryId = CategoryService.instance.categoryCol.doc().id;
    await CategoryService.instance.categoryCol.doc(categoryId).set(categoryData);
    return Category.fromMap(map: categoryData, id: categoryId);
  }

  @override
  String toString() => 'Category(id: $id, name: $name,  description: $description, createdAt: $createdAt)';
}
