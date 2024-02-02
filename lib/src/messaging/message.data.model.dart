/// Post message data
///
/// This is for post messages only.
class PostMessageData {
  /// post id
  String id;
  String category;

  PostMessageData({
    required this.id,
    required this.category,
  });

  factory PostMessageData.fromMap(Map<String, dynamic> map) {
    return PostMessageData(
      id: map['id'],
      category: map['category'],
    );
  }
}

/// Chat message data
///
/// This is for chat messages only.
class ChatMessageData {
  String senderUid;
  String messageId;
  String roomId;

  ChatMessageData({
    required this.senderUid,
    required this.messageId,
    required this.roomId,
  });

  factory ChatMessageData.fromMap(Map<String, dynamic> map) {
    return ChatMessageData(
      senderUid: map['senderUid'],
      messageId: map['messageId'],
      roomId: map['roomId'],
    );
  }
}
