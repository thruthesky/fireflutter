import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:typesense/typesense.dart';

class TypesenceDocType {
  TypesenceDocType._();
  static const user = "user";
  static const post = "post";
  static const comment = "comment";
}

class TypesenseService {
  static TypesenseService? _instance;
  static TypesenseService get instance => _instance ??= TypesenseService._();
  TypesenseService._();

  late final String searchCollection;
  late final Client client;

  init({
    required String apiKey,
    required String scheme,
    required String host,
    required int port,

    /// the name of the collection in Typesense
    required String searchCollection,
  }) {
    this.searchCollection = searchCollection;
    client = Client(Configuration(
      apiKey,
      nodes: {
        Node.withUri(
          Uri(
            scheme: scheme,
            host: host,
            port: port,
          ),
        ),
      },
      numRetries: 3, // A total of 4 tries (1 original try + 3 retries)
      // Sometimes it is slow, so it might not proceed if it took a bit long.
      // To be confirmed if how many seconds are needed.
      connectionTimeout: const Duration(seconds: 20),
    ));
  }

  /// Search
  /// returns SearchResult
  Future<SearchResult> search({
    required Map<String, dynamic> searchParameters,
    // NOTE that collection here must have the correct default value
    // By default it uses `searchCollection` that was set upon init()
    String? collection,
  }) async {
    collection ??= searchCollection;
    dog("searchCollection: $collection");
    dog('searchParameters: $searchParameters');
    final re =
        await client.collection(collection).documents.search(searchParameters);
    return SearchResult.fromJson(re);
  }

  /// This delete is only gonna delete record in
  /// Typesense, not in RTDB.
  ///
  /// Can use ID as string to delete into Typesense
  ///
  // Future<Map<String, dynamic>> delete(Object obj) async {
  //   String id;
  //   if (obj is String) {
  //     id = obj;
  //   } else if (obj is Post) {
  //     id = obj.id;
  //   } else if (obj is Comment) {
  //     id = obj.id;
  //   } else {
  //     throw Issue('Invalid object type: ${obj.runtimeType}');
  //   }
  //   return await client.collection(searchCollection).document(id).delete();
  // }

  /// Update the index for the user.
  Future<Map<String, dynamic>> _upsertUser(UserModel user) async {
    final data = {
      'id': user.uid,
      'uid': user.uid,
      'type': TypesenceDocType.user,
      'createdAt': user.createdAt,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'isVerified': user.isVerified,
    };
    return await client.collection(searchCollection).documents.upsert(data);
  }

  /// Updates the index for the post.
  Future<Map<String, dynamic>> _upsertPost(Post post) async {
    final data = {
      'id': post.id,
      'type': TypesenceDocType.post,
      'createdAt': post.createdAt.millisecondsSinceEpoch,
      'uid': post.uid,
      'title': post.title,
      'content': post.content,
      'category': post.category,
      // 'urls': post.urls, we only save url
      if (post.urls.isNotEmpty) 'url': post.urls[0],
    };
    return await client.collection(searchCollection).documents.upsert(data);
  }

  /// Updates the index for the comment.
  Future<Map<String, dynamic>> _upsertComment(Comment comment) async {
    final data = {
      'id': comment.id,
      'type': TypesenceDocType.comment,
      'createdAt': comment.createdAt,
      'category': comment.category,
      'postId': comment.postId,
      'parentId': comment.parentId,
      'content': comment.content,
      'uid': comment.uid,
      // 'urls': post.urls, we only save url
      if (comment.urls.isNotEmpty) 'url': comment.urls[0],
    };
    return await client.collection(searchCollection).documents.upsert(data);
  }

  // Reindex a user in Typesense
  Future<void> reindexUser() async {
    dog('Re-indexing users');
    await client.collection(searchCollection).documents.delete({
      'filter_by': 'type:=user',
    });
    final snapshot =
        await FirebaseDatabase.instance.ref(UserModel.nodeName).get();
    for (final e in (snapshot.value as Map).entries) {
      final user = UserModel.fromJson(e.value, uid: e.key);
      await _upsertUser(user);
      dog('Re-indexing user: ${user.uid} - ${user.displayName}');
    }
  }

  /// Re-index the posts and comments for the category only.
  Future<void> reindexCategory(String category) async {
    dog('Re-indexing category: $category');
    await deleteCategory(category);
    dog('Re-indexing posts for category: $category');
    final postSnapshot = await Post.categoryRef(category).get();
    List<Future> futures = [];
    for (final e in (postSnapshot.value as Map).entries) {
      final post = Post.fromJson(e.value, id: e.key, category: category);
      if (!post.deleted) {
        futures.add(_upsertPost(post));
        dog('Re-indexing post: ${post.id}');
        futures.add(_reindexComments(post.id));
      }
      // deleted or not, reindex comments under this post,
      // since deleted post can still have comments.
      futures.add(_reindexComments(post.id));
    }
    await Future.wait(futures);
    return;
  }

  Future<void> _reindexComments(String postId) async {
    dog('Re-indexing comments for post: $postId');
    final commentsSnapshot = await Comment.commentsRef.child(postId).get();
    dog("Retrieved: ${commentsSnapshot.value}");
    List<Future> futures = [];
    for (final commentSnapshot in commentsSnapshot.children) {
      final comment = Comment.fromJson(
          commentSnapshot.value as Map, commentSnapshot.key!,
          postId: postId);
      if (!comment.deleted) {
        futures.add(_upsertComment(comment));
        dog('Re-indexing comment: ${comment.id}');
      }
    }
    await Future.wait(futures);
    return;
  }

  Future<Map<String, dynamic>> deleteCategory(String category) async {
    dog('Deleting category: $category');
    return await client.collection(searchCollection).documents.delete({
      'filter_by': 'type:=[post,comment] && category:=$category',
    });
  }
}
