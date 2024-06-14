/// Post message data
///
/// This is for post messages only.
class CommentMessaging {
  // It was noted that is id is supposedly the post id but due to
  // some logic it might be the comment id.
  String id;
  String category;
  // Need to confirm because comment notification have id as well
  String postId;

  CommentMessaging({
    required this.id,
    required this.category,
    required this.postId,
  });

  factory CommentMessaging.fromMap(Map<String, dynamic> map) {
    return CommentMessaging(
      id: map['id'],
      category: map['category'],
      postId: map['postId'],
    );
  }
}
