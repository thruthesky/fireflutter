/// # Search Result Doc
/// This is needed to prevent typing error in Search result
/// with Typesense
///
/// Database is for users, posts, comments
class SearchResultDoc {
  final String id;
  final String type;
  final int createdAt;

  // User
  final String? uid;
  final String? displayName;
  final String? name;
  final String? photoUrl;
  final bool? isVerified;
  // Do we have first name, middle name, last name?
  // (be reminded that we have to update the collection in Typesense if we are adding fields)

  // Post
  // for post's `id`, use the id above
  final String? title;
  final String? content;
  final String? category;
  // `uid` is already given above
  // `likes` is not added (conversion will be complicated, can add later)
  // final int? noOfLikes; // being removed
  // we only use one url in here
  final List<String>? urls;
  // `comments` is not added (conversion will be complicated, can add later)
  // final int? noOfComments; // being removed
  // final bool? deleted; // being removed

  // Comment
  // for comment's `id`, use the id above
  // for comment's `category`, use the category above
  final String? postId;
  final String? parentId;
  // for comment's `content`, it is shared with post above
  // `uid` is already given above
  // `urls` is already given in post above
  // final int? depth; // being removed

  SearchResultDoc({
    required this.id,
    required this.type,
    required this.createdAt,
    // User
    this.uid,
    this.displayName,
    this.name,
    this.photoUrl,
    this.isVerified,
    // Post
    this.title,
    this.content,
    this.category,

    /// only one url is saved in Typesense
    /// In Typesense it is saved as url string
    this.urls,
    // Comment
    this.postId,
    this.parentId,
    // this.depth,
  });

  factory SearchResultDoc.fromJson(Map<String, dynamic> json) {
    return SearchResultDoc(
      // BE REMINDED when we update anything here,
      // we should also update the structure of
      // collection in our Typesense.
      id: json['id'],
      type: json['type'],
      createdAt: json['createdAt'],

      // User
      uid: json['uid'],
      displayName: json['displayName'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      isVerified: json['isVerified'],

      // Post
      title: json['title'],
      content: json['content'],
      category: json['category'],
      // <---x  We only save the first url for Typesense
      // This will ensure if we have url -> [url]
      urls: ((json['url'] ?? '') as String).isEmpty ? null : [json['url']],

      // Comment
      postId: json['postId'],
      parentId: json['parentId'],
    );
  }

  Map<String, dynamic> toJson() {
    // No need to add `(if something.isNotNull)`
    // because it doesn't really matter
    // but please correct it if wrong
    return {
      'id': id,
      'type': type,
      'createdAt': createdAt,

      // User
      'uid': uid,
      'displayName': displayName,
      'name': name,
      'photoUrl': photoUrl,
      'isVerified': isVerified,

      // Post
      'title': title,
      'content': content,
      'category': category,
      'urls': urls, // <---x  We only save the first url
      // Comment
      'postId': postId,
      'parentId': parentId,
    };
  }

  @override
  String toString() => toJson().toString();
}
