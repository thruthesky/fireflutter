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

  /// Creates a category object from an id.
  ///
  /// It contains only the id and the rest of the fields are empty.
  factory Category.fromId(String id) {
    return Category(
      id: id,
      name: '',
      description: '',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      uid: '',
    );
  }

  factory Category.fromMap({required Map<String, dynamic> map, required id}) {
    return Category(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
      createdAt: (map['createdAt'] is Timestamp) ? map['createdAt'] : Timestamp.now(),
      updatedAt: (map['updatedAt'] is Timestamp) ? map['createdAt'] : Timestamp.now(),
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
    await CategoryService.instance.categoryCol.doc(categoryId).set(categoryData);
    categoryData['createdAt'] = Timestamp.now();
    categoryData['updatedAt'] = Timestamp.now();
    return Category.fromMap(map: categoryData, id: categoryId);
  }

  /// Updates a category
  ///
  /// [categoryId] is the id of the category to update. If it's null, it will
  /// use the id of current category object.
  ///
  /// Note, this can be used by a user to update the no of posts and categories.
  Future<void> update({
    String? name,
    String? description,
    FieldValue? noOfPosts,
    FieldValue? noOfComments,
  }) async {
    final Map<String, dynamic> data = {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (noOfPosts != null) 'noOfPosts': noOfPosts,
      if (noOfComments != null) 'noOfComments': noOfComments,
    };
    await CategoryService.instance.categoryCol.doc(id).update(data);
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
