/// Chat messaging model
///
/// This is for chat messages only.
class ChatMessaging {
  String senderUid;
  String messageId;
  String roomId;

  ChatMessaging({
    required this.senderUid,
    required this.messageId,
    required this.roomId,
  });

  factory ChatMessaging.fromMap(Map<String, dynamic> map) {
    return ChatMessaging(
      senderUid: map['senderUid'],
      messageId: map['messageId'],
      roomId: map['roomId'],
    );
  }
}
