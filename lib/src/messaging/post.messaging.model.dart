/// Post message data
///
/// This is for post messages only.
class PostMessaging {
  /// post id
  String id;
  String category;

  PostMessaging({
    required this.id,
    required this.category,
  });

  factory PostMessaging.fromMap(Map<String, dynamic> map) {
    return PostMessaging(
      id: map['id'],
      category: map['category'],
    );
  }
}
