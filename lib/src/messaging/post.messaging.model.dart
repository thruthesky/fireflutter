/// Post message data
///
/// This is for post messages only.
class PostMessagingModel {
  /// post id
  String id;
  String category;

  PostMessagingModel({
    required this.id,
    required this.category,
  });

  factory PostMessagingModel.fromMap(Map<String, dynamic> map) {
    return PostMessagingModel(
      id: map['id'],
      category: map['category'],
    );
  }
}
