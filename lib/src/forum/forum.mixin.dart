import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

enum ReportTarget {
  post,
  comment,
  user,
  chat,
}

mixin ForumMixin {
  /// [post] is the post
  /// [comment] is null for immediate child comment or the parent comment
  ///

  BuildContext get context => FireFlutter.instance.context;

  /// Returns Firestore instance. Firebase database instance.
  FirebaseFirestore get db => FirebaseFirestore.instance;
  bool get signedIn => UserService.instance.signedIn;
  bool get notSignedIn => UserService.instance.notSignedIn;

  CollectionReference get userCol => db.collection('users');
  CollectionReference get categoryCol => db.collection('categories');
  CollectionReference get postCol => db.collection('posts');
  CollectionReference get commentCol => db.collection('comments');

  CollectionReference get reportCol => db.collection('reports');
  CollectionReference get feedCol => db.collection('feeds');

  // settings has forum settings.
  CollectionReference get settingDoc => db.collection('settings');

  // Forum category menus
  DocumentReference get forumSettingDoc => settingDoc.doc('forum');

  // Forum category menus
  DocumentReference reportDoc(String id) => reportCol.doc(id);

  // Jobs
  CollectionReference get jobs => db.collection('jobs');
  CollectionReference get jobSeekers => db.collection('job-seekers');

  DocumentReference categoryDoc(String id) {
    return db.collection('categories').doc(id);
  }

  DocumentReference postDoc(String id) {
    return postCol.doc(id);
  }

  Query<PostModel> postsQuery({
    int limit = 10,
    bool decending = true,
  }) {
    return postCol
        .limit(limit)
        .orderBy('createdAt', descending: decending)
        .withConverter<PostModel>(
          fromFirestore: (snapshot, _) => PostModel.fromSnapshot(snapshot),
          toFirestore: (post, _) => post.map,
        );
  }

  // Use this for static.
  static DocumentReference postDocument(String id) {
    return FirebaseFirestore.instance.collection('posts').doc(id);
  }

  DocumentReference voteDoc(String id) {
    return postCol.doc(id).collection('votes').doc(UserService.instance.uid);
  }

  DocumentReference commentDoc(String commentId) {
    return commentCol.doc(commentId);
  }

  DocumentReference commentVoteDoc(String commentId) {
    return commentDoc(commentId)
        .collection('votes')
        .doc(UserService.instance.uid);
  }

  onReply(PostModel post, [CommentModel? comment]) async {
    if (UserService.instance.notSignedIn) return ffError('Sign-in first!');

    return showDialog(
      context: context,
      builder: (bc) {
        return CommentEditDialog(
          onCancel: Navigator.of(context).pop,
          onSubmit: (Json form, progress) async {
            try {
              progress(true);
              await CommentModel().create(
                postId: post.id,
                parentId: comment?.id ?? post.id,
                content: form['content'],
                files: form['files'],
              );
              Navigator.of(context).pop();
            } catch (e) {
              ffError(e);
              progress(false);
              rethrow;
            }
          },
        );
      },
    );
  }

  //
  Future<PostModel?> onPostEdit({
    PostModel? post,
    String? category,
    String? subcategory,
    Map<String, String>? categories,
    bool photo = false,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: Icon(Icons.arrow_back_ios),
                      ),
                      Text('Post edit'),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 32),
                  PostForm(
                    post: post,
                    categories: categories,
                    photo: photo,
                    heightBetween: 32,
                    category:
                        (post?.id == null || post?.id == "") ? category : '',
                    subcategory: post == null ? subcategory : '',
                    onCreate: (post) => Navigator.of(context).pop(post),
                    onUpdate: (post) => Navigator.of(context).pop(post),
                    onCancel: Navigator.of(context).pop,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// This is for comment only.
  onCommentEdit(CommentModel comment) async {
    return showDialog(
      context: context,
      builder: (bc) {
        return CommentEditDialog(
          comment: comment,
          onCancel: Navigator.of(context).pop,
          // onError: service.error,
          onSubmit: (Json form, progress) async {
            try {
              progress(true);
              await comment.update(
                content: form['content'],
                files: form['files'],
              );
              Navigator.of(context).pop();
            } catch (e) {
              ffError(e);
              rethrow;
            }
          },
        );
      },
    );
  }

  /// Post or comment delete
  onDelete(dynamic postOrComment) async {
    try {
      final re = await ffConfirm('Delete', "Do you want to delete?");
      if (re != true) return;

      if (postOrComment is PostModel) {
        await postOrComment.delete();
        await ffAlert('Post deleted', 'You have deleted this post.');
      } else if (postOrComment is CommentModel) {
        await postOrComment.delete();
        await ffAlert('Comment deleted', 'You have deleted this comment.');
      }
    } catch (e) {
      ffError(e);
      rethrow;
    }
  }

  onLike(dynamic postOrComment) async {
    try {
      await postOrComment.feedLike();
      // await feed(postOrComment.path, 'like');
    } catch (e) {
      ffError(e);
      rethrow;
    }
  }

  @Deprecated('Do not do dislike.')
  onDislike(dynamic postOrComment) async {
    try {
      await postOrComment.feedDislike();
      // await feed(postOrComment.path, 'dislike');
    } catch (e) {
      ffError(e);
      rethrow;
    }
  }

  onReport(dynamic postOrComment) async {
    log("type of post or comment: ${postOrComment.runtimeType}");
    final input = TextEditingController(text: '');
    String? re = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason'),
            TextField(
              controller: input,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(input.text);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );

    if (re == null) return;
    try {
      await postOrComment.report(input.text);
      String type = postOrComment is PostModel ? 'post' : 'comment';
      ffAlert('Report success', 'You have reported this $type');
    } catch (e) {
      ffError(e);
      rethrow;
    }
  }

  /// Create a report document.
  ///
  /// [uid] is the uid of the reporter.
  ///
  /// [reporteeUid] is the uid of the user being reported.
  ///
  Future<void> createReport({
    required ReportTarget target,
    required String targetId,
    String? reason,
    String? reporteeUid,
  }) async {
    final uid = UserService.instance.uid;
    final docId = "${target.name}-$targetId-$uid";

    final reportSnap = await reportCol.doc(docId).get();
    if (reportSnap.exists) {
      throw target == ReportTarget.post
          ? ERROR_POST_ALREADY_REPORTED
          : ERROR_COMMENT_ALREADY_REPORTED;
    }

    return reportCol.doc(docId).set({
      'uid': uid,
      'target': target.name,
      'targetId': targetId,
      'timestamp': FieldValue.serverTimestamp(),
      if (reason != null) 'reason': reason,
      if (reporteeUid != null) 'reporteeUid': reporteeUid,
    });
  }

  /// Show image on a seperate dialog.
  ///
  onImageTapped(int initialIndex, List<String> files) {
    // return alert('Display original image', 'TODO: display original images with a scaffold.');
    return showDialog(
      context: context,
      builder: (context) => ImageViewer(files, initialIndex: initialIndex),
    );
  }

  @Deprecated("Dont use this. Use butotnBuilder()")
  Widget buildButton(label, Function() onTap) {
    return GestureDetector(
      child: Chip(
        label: Text(label),
      ),
      onTap: onTap,
    );
  }

  Widget buttonBuilder(label, Function() onTap) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> increaseForumViewCounter(DocumentReference doc) {
    return doc.update({'viewCounter': FieldValue.increment(1)});
  }

  /// Like, dislike
  ///
  /// Don't put it in cloud functions since;
  /// - the logic is a bit complicated and it's easir to make it work on client
  ///   side.
  /// - It is not a critical work. It is okay that there might be an unexpted
  ///   behaviour.
  ///
  /// [targetDocPath] is the path of target document. The document could be one
  /// post, comment, or UserService.instance.
  /// [likeOrDisliek] can be one of 'like' or 'dislike'.
  ///
  Future<void> feed(String targetDocPath, String likeOrDislike) async {
    // if (notSignedIn) throw ERROR_SIGN_IN_FIRST_FOR_FEED;

    final targetDocRef = db.doc(targetDocPath);

    String feedDocId = "${targetDocRef.id}-${UserService.instance.uid}";

    // if feed not exists, then create new one and increase the number on doc.
    // if existing feed is same as new feed, then remove the feed and decrease the number on doc.
    // if existing feed is different from new feed, then change the feed and decrease one from the

    final feedDocRef = feedCol.doc(feedDocId);

    try {
      final feedDoc = await feedDocRef.get();
      if (feedDoc.exists) {
        // feed exists.
        final data = feedDoc.data() as Json;
        if (data['feed'] == likeOrDislike) {
          // same feed again
          final batch = db.batch();
          batch.delete(feedDocRef);
          batch.set(
            targetDocRef,
            {likeOrDislike: FieldValue.increment(-1)},
            SetOptions(merge: true),
          );
          return batch.commit();
        } else {
          // different feed
          final batch = db.batch();
          batch.set(feedDocRef, {'feed': likeOrDislike});
          if (likeOrDislike == 'like') {
            batch.set(
              targetDocRef,
              {
                'like': FieldValue.increment(1),
                'dislike': FieldValue.increment(-1),
              },
              SetOptions(merge: true),
            );
          } else {
            batch.set(
              targetDocRef,
              {
                'like': FieldValue.increment(-1),
                'dislike': FieldValue.increment(1),
              },
              SetOptions(merge: true),
            );
          }
          return batch.commit();
        }
      } else {
        await createFeed(feedDocRef, targetDocRef, likeOrDislike);
      }
    } catch (e) {
      await createFeed(feedDocRef, targetDocRef, likeOrDislike);
    }
  }

  Future<void> createFeed(feedDocRef, targetDocRef, likeOrDislike) {
    // feed doc does not exist. create one.
    final batch = db.batch();
    batch.set(feedDocRef, {'feed': likeOrDislike});
    batch.set<Map<String, dynamic>>(
      targetDocRef,
      {likeOrDislike: FieldValue.increment(1)},
      SetOptions(merge: true),
    );
    return batch.commit();
  }
}
