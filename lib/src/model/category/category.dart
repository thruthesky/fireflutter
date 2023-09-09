import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category with FirebaseHelper {
  static const String collectionName = 'categories';
  static DocumentReference doc(String categoryId) =>
      CategoryService.instance.categoryCol.doc(categoryId);
  final String id;
  final String name;
  final String? description;

  /// This holds the original JSON document data of the user document. This is
  /// useful when you want to save custom data in the user document.
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Map<String, dynamic> data;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  Category({
    required this.id,
    this.name = '',
    this.description,
    dynamic createdAt,
  }) : createdAt =
            (createdAt is Timestamp) ? createdAt.toDate() : DateTime.now();

  factory Category.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Category.fromJson({
      ...documentSnapshot.data() as Map<String, dynamic>,
      ...{'id': documentSnapshot.id}
    });
  }

  /// Creates a category object from an id.
  ///
  /// It contains only the id and the rest of the fields are empty.
  factory Category.fromId(String id) {
    return Category(
      id: id,
      name: '',
      description: '',
      createdAt: DateTime.now(),
    );
  }

  @Deprecated('Use fromJson instead')
  factory Category.fromMap({required Map<String, dynamic> map, required id}) {
    map['id'] = id;
    return Category.fromJson(map);
  }

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json)..data = json;
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @Deprecated('Use toJson instead')
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Creates a category and returns the category.
  ///
  static Future create({
    required String categoryId,
    required String name,
    String? description,
  }) async {
    final String myUid = FirebaseAuth.instance.currentUser!.uid;
    final Map<String, dynamic> categoryData = {
      'name': name,
      if (description != null) 'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'uid': myUid,
    };
    return await doc(categoryId).set(categoryData);
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

  /// Get the category or throw an exception if it does not exist.
  ///
  static Future<Category> get(String categoryId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(categoryId)
        .get();
    if (snapshot.exists == false)
      throw Exception('Category $categoryId does not exist');
    return Category.fromDocumentSnapshot(snapshot);
  }

  Future delete() async {
    return await doc(id).delete();
  }

  @override
  String toString() => 'Category(${toJson()})';
}
