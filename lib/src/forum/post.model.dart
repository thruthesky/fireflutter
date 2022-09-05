import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:jiffy/jiffy.dart';

/// PostModel
///
/// PostModel and comment are a lot similiar. So both uses the same model.
/// Refer readme for details
class PostModel with ForumMixin implements Article {
  PostModel({
    this.id = '',
    this.category = '',
    this.subcategory = '',
    this.title = '',
    this.content = '',
    this.summary = '',
    this.uid = '',
    this.noOfComments = 0,
    this.hasPhoto = false,
    this.files = const [],
    this.point = 0,
    this.like = 0,
    this.dislike = 0,
    this.deleted = false,
    this.year = 0,
    this.month = 0,
    this.day = 0,
    this.week = 0,
    this.createdAt,
    this.updatedAt,
    data,
    this.isHtmlContent = false,
  }) : data = data ?? {};

  /// data is the document data object.
  Json data;

  String id;
  String get path => postDoc(id).path;

  /// Category of the post.
  ///
  /// Category is not needed for comment.
  String category;
  String subcategory;

  String title;
  String get displayTitle {
    final _title = deleted ? 'post-title-deleted' : title;
    if (_title.trim() == '') {
      return '';
    } else {
      return _title;
    }
  }

  String content;
  String get displayContent {
    return deleted ? 'post-content-deleted' : content;
  }

  String summary;

  bool deleted;

  String uid;

  bool get isMine => UserService.instance.uid == uid;

  int noOfComments;

  bool get hasComments => noOfComments > 0;

  bool hasPhoto;
  bool isHtmlContent;
  List<String> files;

  int point;

  int like;
  int dislike;

  int year;
  int month;
  int day;
  int week;

  Timestamp? createdAt;
  Timestamp? updatedAt;

  /// To open the post data. Use this to display post content or not on post list screen.
  bool open = false;

  List<CommentModel> comments = [];

  @Deprecated("Create post with PostApi.")
  factory PostModel.fromDoc(DocumentSnapshot doc) {
    return PostModel.fromJson(doc.data() as Json, doc.id);
  }

  /// Get document data of map and convert it into post model
  ///
  /// If post is created via http, then it will have [id] inside `data`.
  factory PostModel.fromJson(Json data, [String? id]) {
    String content = data['content'] ?? '';

    /// Check if the content has any html tag.
    bool html = _isHtml(content);

    // TODO: this might be unnecessary after all existing post's timestamp is converted on the backend.
    Timestamp _createdAt = data['createdAt'] is int
        ? Timestamp.fromMillisecondsSinceEpoch(data['createdAt'] * 1000)
        : data['createdAt'];

    Timestamp _updatedAt = data['updatedAt'] is int
        ? Timestamp.fromMillisecondsSinceEpoch(data['updatedAt'] * 1000)
        : data['updatedAt'];

    final post = PostModel(
      id: id ?? data['id'],
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      title: data['title'] ?? '',
      content: content,
      summary: data['summary'] ?? '',
      isHtmlContent: html,
      noOfComments: data['noOfComments'] ?? 0,
      hasPhoto: data['hasPhoto'] ?? false,
      files: new List<String>.from(data['files'] ?? []),
      deleted: data['deleted'] ?? false,
      uid: data['uid'] ?? '',
      point: data['point'] ?? 0,
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      day: data['day'] ?? 0,
      week: data['week'] ?? 0,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      // createdAt: data['createdAt'] ?? 0,
      // updatedAt: data['updatedAt'] ?? 0,
      data: data,
    );

    /// If the post is opened, then maintain the status.
    /// If the [open] property is not maintained,
    /// every time the document had updated, `PostModel.fromJson` will be called again
    /// and [open] becomes false, and the post may be closed.
    /// For instance, when user likes the post and the post closes on post list.
    // if (PostService.instance.posts[post.id] != null) {
    //   final p = PostService.instance.posts[post.id]!;
    //   post.open = p.open;
    // }

    /// Keep loaded post into memory.
    // PostService.instance.posts[post.id] = post;

    return post;
  }

  /// Get indexed document data from meilisearch of map and convert it into post model
  @Deprecated('Use PostModel.fromTypesense')
  factory PostModel.fromMeili(Json data, String id) {
    return PostModel(
      id: id,
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      uid: data['uid'] ?? '',
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      deleted: data.containsKey('deleted') ? data['deleted'] == 'Y' : false,
      createdAt: data['createdAt'] ?? 0,
      updatedAt: data['updatedAt'] ?? 0,
      data: data,
    );
  }

  /// Get indexed document data from typesense of map and convert it into post model
  factory PostModel.fromTypesense(Json data, String id) {
    return PostModel(
      id: id,
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      title: data['title'] ?? '',
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

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'category': category,
      'subcategory': subcategory,
      'title': title,
      'content': content,
      'summary': summary,
      'isHtmlContent': isHtmlContent,
      'noOfComments': noOfComments,
      'hasPhoto': hasPhoto,
      'files': files,
      'deleted': deleted,
      'uid': uid,
      'point': point,
      'like': like,
      'dislike': dislike,
      'year': year,
      'month': month,
      'day': day,
      'week': week,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'data': data,
    };
  }

  @override
  String toString() {
    return '''PostModel($map)''';
  }

  Future<void> report(String? reason) {
    /// TODO change it to firestore call.
    return Future.value(0);

    // return ReportApi.instance.report(
    //   target: 'post',
    //   targetId: id,
    //   reason: reason,
    // );
  }

  /// Create a post with extra data
  ///
  /// [documentId] is the document id to create with. Read readme for details.
  ///
  /// ```dart
  /// final ref = await PostModel(
  ///   category: Get.arguments['category'],
  ///   title: title.text,
  ///   content: content.text,
  /// ).create(extra: {'yo': 'hey'});
  /// print('post created; ${ref.id}');
  /// ```
  ///
  /// Read readme for [hasPhoto]
  Future<DocumentReference<Object?>> create({
    required String category,
    required String title,
    required String content,
    String? subcategory,
    String? documentId,
    List<String>? files,
    String? summary,
    Json extra = const {},
  }) {
    if (signedIn == false) throw ERROR_SIGN_IN_FIRST_FOR_POST_CREATE;
    if (UserService.instance.user.ready == false) {
      throw UserService.instance.user.profileError;
    }
    if (category.isEmpty) throw 'Category is empty on post create.';

    final j = Jiffy();
    final createData = {
      'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      'title': title,
      'content': content,
      if (summary != null && summary != '') 'summary': summary,
      if (files != null) 'files': files,
      'uid': UserService.instance.uid,
      'hasPhoto': (files == null || files.length == 0) ? false : true,
      'deleted': false,
      'noOfComments': 0,
      'year': j.year,
      'month': j.month,
      'day': j.date,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (documentId != null && documentId != '') {
      return postCol.doc(documentId).set({...createData, ...extra}).then(
          (value) => postCol.doc(documentId));
    } else {
      return postCol.add({...createData, ...extra});
    }
  }

  /// TODO update post
  Future<void> update({
    required String title,
    required String content,
    List<String>? files,
    String? summary,
    Json extra = const {},
  }) {
    if (deleted) throw ERROR_ALREADY_DELETED;
    if (id.isEmpty) throw 'Post id empty on update';
    if (uid != UserService.instance.uid) throw 'Not your post.';

    return postDoc(id).update({
      ...{
        'title': title,
        'content': content,
        if (files != null) 'files': files,
        if (summary != null) 'summary': summary,
        'hasPhoto': (files == null || files.length == 0) ? false : true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      ...extra
    });
  }

  Future<PostModel> get(String postId) async {
    final snapshot = await postDoc(postId).get();
    return PostModel.fromJson(snapshot.data() as Json, snapshot.id);
  }

  /// See readme.
  Future<String> delete() async {
    /// TODO delete post
    return Future.value('');
  }

  /// Increases no of the post read.
  ///
  /// Note that, this is not a recommended way of counting post view.
  /// When you do this on post view action, the document will be updated every
  /// time the user opens the document. and if the app is listening document's
  /// change, or if a cloud function is listing on `post update event`, the cost
  /// will be increased.
  ///
  /// Be careful using this.
  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(postDoc(id));
  }

  ///
  Future feedLike() {
    return feed(path, 'like');
  }

  ///
  Future feedDislike() {
    return feed(path, 'dislike');
  }

  /// Returns short date time string.
  ///
  /// It returns one of 'MM/DD/YYYY' or 'HH:MM AA' format.
  String get shortDateTime {
    return shortDateTimeFromFirestoreTimestamp(createdAt);
    // final date = DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
    // final today = DateTime.now();
    // bool re;
    // if (date.year == today.year && date.month == today.month && date.day == today.day) {
    //   re = true;
    // } else {
    //   re = false;
    // }
    // return re ? DateFormat.jm().format(date).toLowerCase() : DateFormat.yMd().format(date);
  }

  /// If the post was created just now (in 5 minutes), then returns true.
  ///
  /// Use this to check if this post has just been created.
  // bool get justNow {
  //   final date = DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
  //   final today = DateTime.now();
  //   final diff = today.difference(date);
  //   return diff.inMinutes < 5;
  // }

  /// Returns true if the text is HTML.
  static bool _isHtml(String t) {
    t = t.toLowerCase();

    if (t.contains('</h1>')) return true;
    if (t.contains('</h2>')) return true;
    if (t.contains('</h3>')) return true;
    if (t.contains('</h4>')) return true;
    if (t.contains('</h5>')) return true;
    if (t.contains('</h6>')) return true;
    if (t.contains('</hr>')) return true;
    if (t.contains('</li>')) return true;
    if (t.contains('<br>')) return true;
    if (t.contains('<br/>')) return true;
    if (t.contains('<br />')) return true;
    if (t.contains('<p>')) return true;
    if (t.contains('</div>')) return true;
    if (t.contains('</span>')) return true;
    if (t.contains('<img')) return true;
    if (t.contains('</em>')) return true;
    if (t.contains('</b>')) return true;
    if (t.contains('</u>')) return true;
    if (t.contains('</strong>')) return true;
    if (t.contains('</a>')) return true;
    if (t.contains('</i>')) return true;

    return false;
  }
}
