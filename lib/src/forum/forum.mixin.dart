import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/fireflutter.instance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin ForumMixin {
  /// [post] is the post
  /// [comment] is null for immediate child comment or the parent comment
  ///

  BuildContext get context => Get.context!;

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

  onReply(Post post, [Comment? comment]) async {
    if (UserService.instance.notSignedIn)
      return ffError(context, 'Sign-in first!');

    return showDialog(
      context: context,
      builder: (bc) {
        return CommentEditDialog(
          onCancel: Get.back,
          // onError: service.error,
          onSubmit: (Json form, progress) async {
            try {
              progress(true);
              await Comment.create(
                postId: post.id,
                parentId: comment?.id ?? post.id,
                content: form['content'],
                files: form['files'],
              );
              Get.back();
            } catch (e, stack) {
              FireFlutter.instance.error(e, stack);
              progress(false);
              rethrow;
            }
          },
        );
      },
    );
  }

  //
  Future<Post?> onPostEdit({
    Post? post,
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
                        onPressed: Get.back,
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
                    onCreate: (id) => Get.back(result: id),
                    onUpdate: (id) => Get.back(result: id),
                    onCancel: Get.back,
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
  onCommentEdit(Comment comment) async {
    return showDialog(
      context: context,
      builder: (bc) {
        return CommentEditDialog(
          comment: comment,
          onCancel: Get.back,
          // onError: service.error,
          onSubmit: (Json form, progress) async {
            try {
              progress(true);
              // TODO comment update
              // await Comment.update(
              //   id: comment.id,
              //   content: form['content'],
              //   files: form['files'],
              // );
              Get.back();
            } catch (e, s) {
              FireFlutter.instance.error(e, s);
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
      final re = await FireFlutter.instance
          .confirm('Delete', "Do you want to delete?");
      if (re != true) return;

      if (postOrComment is Post) {
        await postOrComment.delete();
        await FireFlutter.instance
            .alert('Post deleted', 'You have deleted this post.');
      } else if (postOrComment is Comment) {
        await postOrComment.delete();
        await FireFlutter.instance
            .alert('Comment deleted', 'You have deleted this comment.');
      }
    } catch (e, s) {
      FireFlutter.instance.error(e, s);
      rethrow;
    }
  }

  onLike(dynamic postOrComment) async {
    try {
      await postOrComment.feedLike();
      // await feed(postOrComment.path, 'like');
    } catch (e, s) {
      FireFlutter.instance.error(e, s);
      rethrow;
    }
  }

  @Deprecated('Do not do dislike.')
  onDislike(dynamic postOrComment) async {
    try {
      await postOrComment.feedDislike();
      // await feed(postOrComment.path, 'dislike');
    } catch (e, s) {
      FireFlutter.instance.error(e, s);
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
              Get.back();
            },
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(result: input.text);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );

    if (re == null) return;
    try {
      await postOrComment.report(input.text);
      String type = postOrComment is Post ? 'post' : 'comment';
      FireFlutter.instance
          .alert('Report success', 'You have reported this $type');
    } catch (e, s) {
      FireFlutter.instance.error(e, s);
      rethrow;
    }
  }

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
