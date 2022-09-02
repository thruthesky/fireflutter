import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../fireflutter.dart';

/// Comment
///
/// Refer readme for details
class Comment with ForumMixin implements Article {
  Comment({
    this.id = '',
    required this.postId,
    required this.parentId,
    this.content = '',
    this.like = 0,
    this.dislike = 0,
    required this.uid,
    this.deleted = false,
    this.createdAt = 0,
    this.updatedAt = 0,
    required this.data,
    this.files = const [],
    this.point = 0,
  });

  /// data is the document data object.
  Json data;

  String id;
  String get path => commentDoc(id).path;
  String postId;
  String parentId;

  String content;
  String get displayContent {
    return deleted ? COMMENT_CONTENT_DELETED : content;
  }

  int like;
  int dislike;

  String uid;

  bool deleted;

  List<String> files;

  int updatedAt;
  int createdAt;
  int depth = 0;

  bool get isMine => User.uid == uid;

  bool get hasPhoto => files.length > 0;

  int point;

  /// Get document data of map and convert it into post model
  ///
  /// If the comment is created via https, then the id of comment is inside data.
  factory Comment.fromJson(
    Json data, {
    String? id,
  }) {
    return Comment(
      content: data['content'] ?? '',
      files: new List<String>.from(data['files']),
      id: id ?? data['id'],
      postId: data['postId'],
      parentId: data['parentId'],
      uid: data['uid'],
      point: data['point'] ?? 0,
      deleted: data['deleted'] ?? false,
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      createdAt: data['createdAt'] ?? 0,
      updatedAt: data['updatedAt'] ?? 0,
      data: data,
    );
  }

  /// Get indexed document data from Typesense of map and convert it into comment model
  factory Comment.fromTypesense(Json data, String id) {
    return Comment(
      id: id,
      postId: data['postId'],
      parentId: data['parentId'],
      content: data['content'] ?? '',
      uid: data['uid'] ?? '',
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      deleted: data['deleted'] ?? false,
      createdAt: data['createdAt'] ?? 0,
      updatedAt: data['updatedAt'] ?? 0,
      data: data,
    );
  }

  /// Returns an empty object.
  ///
  /// Use this when you need to use comment model's methods, like when you are
  /// going to create a new comment.
  factory Comment.empty() {
    return Comment(
      postId: '',
      parentId: '',
      content: '',
      uid: '',
      createdAt: 0,
      updatedAt: 0,
      data: {},
    );
  }

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'id': id,
      'postId': postId,
      'parentId': parentId,
      'content': content,
      'depth': depth,
      'files': files,
      'uid': uid,
      'point': point,
      'like': like,
      'dislike': dislike,
      'deleted': deleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'data': data,
    };
  }

  @override
  String toString() {
    return '''Comment($map)''';
  }

  // Map<String, dynamic> get createData {
  //   return {
  //     'content': content,
  //     'uid': UserService.instance.user.uid,
  //     'updatedAt': FieldValue.serverTimestamp(),
  //   };
  // }

  /// Increases the view counter
  ///
  /// Becareful of using this. This makes another document changes and if there are
  /// event trigger functions in cloud functions, those function may be trigger too
  /// often.
  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(commentDoc(id));
  }

  /// Create a comment with extra data
  /// TODO comment create
  static Future<DocumentReference<Object?>> create({
    required String postId,
    required String parentId,
    String content = '',
    List<String> files = const [],
  }) async {
    // bool signedIn = FirebaseAuth.instance.currentUser != null;
    // if (signedIn == false) throw ERROR_SIGN_IN_FIRST;
    // if (UserService.instance.user.exists == false) throw ERROR_USER_DOCUMENT_NOT_EXISTS;
    // if (UserService.instance.user.notReady) throw UserService.instance.user.profileError;
    // final _ = Comment.empty();
    // final ref = await _.commentCol.add({
    //   'postId': postId,
    //   'parentId': parentId,
    //   'content': content,
    //   'files': files,
    //   'createdAt': FieldValue.serverTimestamp(),
    //   'updatedAt': FieldValue.serverTimestamp(),
    //   'uid': FirebaseAuth.instance.currentUser?.uid ?? '',
    // });

    // // final post = await PostModel().get(postId);
    // // await post.increaseNoOfComments();

    // Post.increaseNoOfComments(postId);

    // return ref;

    return Future.value() as dynamic;
  }

  /// TODO update comment
  Future<void> update({
    required String content,
    List<String>? files,
  }) {
    if (deleted) throw ERROR_ALREADY_DELETED;
    return commentDoc(id).update({
      'content': content,
      if (files != null) 'files': files,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// TODO comemnt delete
  Future<String> delete() async {
    return Future.value('');
    // return CommentApi.instance.delete(id);
/*
    if (files.length > 0) {
      for (final url in files) {
        await StorageService.instance.delete(url);
      }
    }
    if (deleted) throw ERROR_ALREADY_DELETED;
    commentDoc(id).update({
      'deleted': true,
      'content': '',
      'files': [],
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return PostModel.decreaseNoOfComments(postId);
    */
  }

  /// TODO comment report
  Future<void> report(String? reason) {
    return Future.value();
    // return ReportApi.instance.report(
    //   target: 'comment',
    //   targetId: id,
    //   reason: reason,
    // );

    // return createReport(
    //   target: 'comment',
    //   targetId: id,
    //   reporteeUid: uid,
    //   reason: reason,
    // );
  }

  Future feedLike() {
    return feed(path, 'like');
  }

  Future feedDislike() {
    return feed(path, 'dislike');
  }

  /// If the post was created just now (in 5 minutes), then returns true.
  ///
  /// Use this to check if this comment has just been created.
  // bool get justNow {
  //   final date = DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
  //   final today = DateTime.now();
  //   final diff = date.difference(today);
  //   return diff.inMinutes < 5;
  // }
}
