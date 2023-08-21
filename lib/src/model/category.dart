import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';

class Category with FirebaseHelper {
  static const String collectionName = 'categories';
  final String id;
  final String name;
  final String? description;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  // TODO for confirmation, since FirebaseHelper already uses uid, we might have problems with tracing what uid are we using.
  // uid should be uid but FirebaseHelper already has it.
  @override
  final String uid;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.uid,
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
      uid: map['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'uid': uid,
    };
  }

  /// Creates a category and returns the category.
  ///
  static Future<Category> create({
    required String categoryId,
    required String name,
    String? description,
  }) async {
    final String myUid = FirebaseAuth.instance.currentUser!.uid;
    final Map<String, dynamic> categoryData = {
      'name': name,
      if (description != null) 'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'uid': myUid,
    };
    // TODO review
    // final categoryId = CategoryService.instance.categoryCol.doc().id;
    await CategoryService.instance.categoryCol.doc(categoryId).set(categoryData);
    categoryData['createdAt'] = Timestamp.now();
    categoryData['updatedAt'] = Timestamp.now();
    return Category.fromMap(map: categoryData, id: categoryId);
  }

  static Future<Category?> get(String categoryId) async {
    final snapshot = await FirebaseFirestore.instance.collection(collectionName).doc(categoryId).get();
    if (!snapshot.exists) {
      return null;
    }
    return Category.fromDocumentSnapshot(snapshot);
  }

  @override
  String toString() =>
      'Category(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, uid: $uid)';
}
