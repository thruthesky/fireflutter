import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Comment {
  /// Paths and Refs
  static String nodeName = 'comments';
  static String comments(String postId) => '$nodeName/$postId';
  static String comment(String postId, String commentId) =>
      '${comments(postId)}/$commentId';

  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference commentsRef = root.child(nodeName);
  static DatabaseReference postComments(String postId) =>
      root.child(comments(postId));

  static DatabaseReference commentRef(String postId, String commentId) =>
      root.child(comment(postId, commentId));

  /// Membrer Variable Reference
  DatabaseReference get likesRef => ref.child(Field.likes);
  DatabaseReference get urlsRef => ref.child(Field.urls);

  /// Member Variables
  final DatabaseReference ref;
  final String id;
  final String? parentId;
  String content;
  final String uid;
  final int createdAt;
  List<String> urls = [];
  int depth;

  /// Category is added here since we cannot access post category using ref..parent..key
  String category;

  bool deleted;

  /// [hasChild] is set to true if the comment have a child. By defualt, it is set to false.
  bool hasChild = false;

  /// [isLastChild] is set to true if the comment is the last child. By default, it is set to false.
  bool isLastChild = true;

  /// [isParentLastChild] is set to true if the parent of current comment is the last child of its parent.
  /// This is used to know if the parent is the last child of its parent.
  /// This is used in drawing the vertical line of comment tree indentation.
  bool isParentLastChild = false;

  /// [hasSiblings] is set to true if the comment has sibilings below his place (not above).
  /// It is like if he has younger brothers or sisters. Not the older ones (place above him).
  /// By default, it is set to true.
  bool hasMoreSibiling = true;

  bool get isMine => uid == myUid;

  /// Get the post id of the comment.
  ///
  String get postId => ref.parent!.key!;

  List<String> likes;
  double get leftMargin {
    if (depth == 0) {
      return 0;
    } else if (depth == 1) {
      return 19;
    } else if (depth == 2) {
      return 46;
    } else if (depth == 3) {
      return 75;
      // } else if (depth == 4) {
      //   return 103;
      // } else if (depth == 5) {
      //   return 131;
      // } else if (depth == 6) {
      //   return 160;
    } else {
      return 103;
    }
  }

  Comment({
    required this.ref,
    required this.id,
    required this.parentId,
    required this.content,
    required this.uid,
    required this.createdAt,
    required this.urls,
    this.depth = 0,
    this.likes = const [],
    this.category = '',
    this.deleted = false,
  });

  // @Deprecated()
  // factory Comment.fromSnapshot(DataSnapshot snapshot) {
  //   return Comment.fromMap(
  //     snapshot.value as Map,
  //     snapshot.key!,
  //     // category: snapshot.ref.parent!.parent!.parent!.key!,
  //     postId: snapshot.ref.parent!.key!,
  //   );
  // }

  factory Comment.fromJson(
    Map<dynamic, dynamic> map,
    String id, {
    // required String category,
    required String postId,
  }) {
    final ref = commentRef(postId, id);
    return Comment(
      ref: ref,
      id: id,
      parentId: map['parentId'],
      content: map['content'],
      uid: map['uid'],
      createdAt: map['createdAt'],
      urls: List<String>.from(map['urls'] ?? []),
      likes: List<String>.from((map['likes'] as Map? ?? {}).keys),
      // Category is added since we cannot access post category using ref..parent..key
      category: map['category'] ?? '',
      deleted: map['deleted'] ?? false,
    );
  }

  /// Create a Comment from a post with empty values.
  ///
  /// Use this factory to create a Comment from a post with empty values.
  /// This is useful to create a new comment or to use other comment model
  /// properties or methods.
  ///
  /// It creates a comment reference with the give post's category and id
  /// along with empty values. So, the comment does not actaully exists in
  /// database, but you can use all the properties and method.
  ///
  /// ```dart
  /// final post = Comment.fromPost(post);
  /// ```
  ///
  /// 새로 작성. 이 때, comment ID 가 ref.push() 로 만들어 진다. 그러나 아직 DB 에는 없는 상태이다.
  ///
  factory Comment.fromPost(Post post) {
    final fakeRef = Comment.postComments(post.id).push();
    return Comment(
      ref: fakeRef,
      id: fakeRef.key!,
      parentId: null,
      content: '',
      category: post.category,
      uid: myUid!,
      createdAt: 0,
      urls: [],
      likes: [],
    );
  }

  /// Create a Comment from a parent comment with empty values.
  factory Comment.fromParent(Comment parent) {
    final fakeRef = parent.ref.parent!.push();
    return Comment(
      ref: fakeRef,
      id: fakeRef.key!,
      parentId: parent.ref.key,
      content: '',
      uid: myUid!,
      createdAt: 0,
      urls: [],
      likes: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'id': id,
        'parentId': parentId,
        'uid': uid,
        'createdAt': createdAt,
        'urls': urls,
        'likes': likes,
        'deleted': deleted,
      };

  @override
  String toString() {
    return 'Comment(ref: $ref, id: $id, parentId: $parentId, content: $content, uid: $uid, createdAt: $createdAt, urls: $urls, likes: $likes, deleted: $deleted)';
  }

  /// Get a comment from the database
  static Future<Comment> get({
    // required String category,
    required String postId,
    required String commentId,
  }) async {
    final snapshot =
        await Comment.commentsRef.child(postId).child(commentId).get();
    return Comment.fromJson(snapshot.value as Map, commentId, postId: postId);
  }

  /// Get all the comments of a post
  ///
  ///
  static Future<List<Comment>> getAll({
    required String postId,
  }) async {
    final snapshot = await Comment.commentsRef.child(postId).get();
    final comments = <Comment>[];
    if (snapshot.value == null) {
      return comments;
    }
    (snapshot.value as Map).forEach((key, value) {
      final comment = Comment.fromJson(
        value,
        key,
        postId: postId,
      );
      comments.add(comment);
    });

    return sortComments(comments);
  }

  /// Get the comments of the post
  static List<Comment> sortComments(List<Comment> comments) {
    /// Sort comments by createdAt
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final List<Comment> newComments = [];

    /// This is the list of comments that are not replies.
    /// It is sorted by createdAt.
    /// If the comment is a reply, it has the parentId of the parent comment.
    /// So, we can find the parent comment by searching the list.
    /// And add the reply to the parent comment's replies.
    for (final comment in comments) {
      if (comment.parentId == null) {
        /// This is the 1st-depth comment (Direct comment under the post)
        /// hasChild, hasSiblings, isLastChild are set here. But needed to be updated later
        newComments.add(comment);
      } else {
        /// Code comes here if the comment is 2nd-depth or more.

        /// Find parent
        /// This comment has parent. Attach it under the parent and update the depth.
        /// Note, there is always a parent comment for a reply. the [parentIndex] will not become -1.
        final parentIndex = newComments.indexWhere(
          (e) => e.id == comment.parentId,
        );
        comment.depth = newComments[parentIndex].depth + 1;
        comment.isLastChild = true;

        /// To inherit the parent comment [isLastChild] property
        comment.isParentLastChild = newComments[parentIndex].isLastChild;

        /// Set parent hasChild true if parentId is not null
        newComments[parentIndex].hasChild = true;

        /// Find sibiling from the list of comment (So, this comment can be attached after the sibiling comment)
        final siblingIndex = newComments.lastIndexWhere(
          (e) => e.parentId == comment.parentId,
        );

        /// If there is no sibling, under the parent (meaning, the is the first child of the parent),
        /// Attche it under the parent.
        if (siblingIndex == -1) {
          /// hasChild, hasSibilings, isLastChild are all set to false by default at this time.
          /// (need to be updated later)
          comment.hasMoreSibiling = false;
          // print('${comment.content} has no sibiling');
          newComments.insert(parentIndex + 1, comment);
        } else {
          /// Sibiling exists!!

          ///
          newComments[siblingIndex].hasMoreSibiling = true;
          comment.hasMoreSibiling = false;

          /// Set the [isLastChild] to true if this comment is last one under the parent (among the sibilings)
          newComments[siblingIndex].isLastChild = false;

          /// 코멘트를 형제와 형제의 자손까지 포함하여, 그 밑에 추가한다.
          int lastSibilingIndex = siblingIndex + 1;
          for (lastSibilingIndex;
              lastSibilingIndex < newComments.length;
              lastSibilingIndex++) {
            /// 각 코멘트의 부모를 경로를 가져온다.
            final List<Comment> parents =
                getParents(newComments[lastSibilingIndex], newComments);

            /// 부모 경로에 같은 부모가 있으면 형제 또는 형제의 자손이다.
            int found = parents.indexWhere((cmt) => cmt.id == comment.parentId);
            // print("i=$lastSibilingIndex, if (found($found) == -1) { //");
            if (found == -1) {
              break;
            }
          }

          /// Runtime comes here if there is a sibling. Meaning, there are comments already attached to the parent.
          /// Attach it after the sibling.
          newComments.insert(lastSibilingIndex, comment);
        }
      }
    }

    return newComments;
  }

  /// Get the parents of the comment.
  ///
  /// It returns the list of parents in the path to the root from the comment.
  /// Use this method to get
  ///   - the parents of the comment. (This case is used by sorting comments and drawing the comment tree)
  ///   - the users(user uid) in the path to the root. Especially to know who wrote the comment in the path to the post
  static List<Comment> getParents(Comment comment, List<Comment> comments) {
    final List<Comment> parents = [];
    Comment? parent = comment;
    while (parent != null) {
      parent = comments.firstWhereOrNull(
        (e) => e.id == parent!.parentId,
      );
      if (parent == null) {
        break;
      }
      parents.add(parent);
    }
    return parents.reversed.toList();
  }

  /// Create a comment
  ///
  /// It's the instance member method. Not a static method. The commend ID is
  /// already inside the object.
  ///
  /// 코멘트 쓰기의 경우, 현재 객체에 ID 가 이미 생성되어 있으므로, ref.set() 으로 생성(저장)하면 된다.
  ///
  /// Note that, this is NOT a static method. It is an instance method that
  /// uses the properties of current instance.
  ///
  /// To create a comment, you need to create a comment model instance from
  /// the post model instance or parent comment model instance.
  ///
  /// ```dart
  /// final comment = Comment.fromPost(post);
  /// await comment.create(content: 'content');
  /// ```
  Future create({
    required String content,
    required String category,
    Comment? parent,
    List<String>? urls,
  }) async {
    if (await ActionLogService.instance.commentCreate.isOverLimit()) return;

    Map<String, dynamic> data = {
      'content': content,
      'parentId': parent?.id,
      'category': category,
      // 'depth': parent?.depth ?? 0,
      'uid': myUid!,
      'createdAt': ServerValue.timestamp,
      'urls': urls,
    };

    await ref.set(data);

    /// Don't wait for calling onCommentCreate.
    final created = await Comment.get(
      // category: category,
      postId: postId,
      commentId: id,
    );

    ForumService.instance.onCommentCreate?.call(created);

    ActionLog.commentCreate(postId: postId, commentId: created.id);
    ActivityLog.commentCreate(postId: postId, commentId: created.id);

    return created;
  }

  Future update({
    String? content,
    List<String>? urls,
    bool? deleted,
  }) async {
    await ref.update({
      if (content != null) 'content': content,
      'urls': urls,
      if (deleted != null) 'deleted': deleted,
    });

    /// Update the current content of the comment.
    if (content != null) this.content = content;
    if (urls != null) {
      this.urls = urls;
    }

    ForumService.instance.onCommentUpdate?.call(this);
  }

  /// Like or unlike
  ///
  /// It loads all the likes and updates.
  Future<void> like({
    required BuildContext context,
  }) async {
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: 'comment-like',
          data: {
            'comment': this,
          });
      if (re != true) return;
    }

    final snapshot = await ref.child(Field.likes).get();
    likes = List<String>.from((snapshot.value as Map? ?? {}).keys);

    if (likes.contains(myUid) == false) {
      ref.child(Field.likes).child(myUid!).set(true);
      likes.add(myUid!);
    } else {
      ref.child(Field.likes).child(myUid!).remove();
      likes.remove(myUid);
    }
  }

  /// Delete post
  ///
  /// If there is no comment, delete the post. Or update the title and content to 'deleted'.
  /// And set the deleted field to true.
  Future<void> delete({
    required BuildContext context,
    bool ask = true,
  }) async {
    /// 로그인 확인
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: 'comment-delete',
          data: {
            'comment': this,
          });
      if (re != true) return;
    }

    /// 자신의 글인지 확인
    if (uid != myUid) {
      error(context: context, message: T.notYourComment.tr);
      return;
    }

    /// 물어보기
    if (ask) {
      final re = await confirm(
        context: context,
        title: T.deleteCommentConfirmTitle.tr,
        message: T.deleteCommentConfirmMessage.tr,
      );
      if (re != true) return;
    }

    await update(
      content: Code.deleted,
      deleted: true,
    );
    deleted = true;
    ForumService.instance.onCommentDelete?.call(this);
  }

  onFieldChange(
    String field,
    Widget Function(dynamic) builder, {
    dynamic initialData,
    Widget? onLoading,
  }) {
    return Value(
      initialData: initialData,
      ref: ref.child(field),
      builder: builder,
      onLoading: onLoading,
    );
  }
}
