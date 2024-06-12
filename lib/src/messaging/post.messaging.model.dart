/// Post message data
///
/// This is for post messages only.
class PostMessaging {
  // It was noted that is id is supposedly the post id but due to
  // some logic it might be the comment id.
  String id;
  String category;
  // Need to confirm because comment notification have id as well
  String? postId;

  PostMessaging({
    required this.id,
    required this.category,
    required this.postId,
  });

  factory PostMessaging.fromMap(Map<String, dynamic> map) {
    return PostMessaging(
      id: map['id'],
      category: map['category'],
      postId: map['postId'],
    );
  }
}
