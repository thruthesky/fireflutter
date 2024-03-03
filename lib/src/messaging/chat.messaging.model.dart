/// Chat messaging model
///
/// This is for chat messages only.
class ChatMessagingModel {
  String senderUid;
  String messageId;
  String roomId;

  ChatMessagingModel({
    required this.senderUid,
    required this.messageId,
    required this.roomId,
  });

  factory ChatMessagingModel.fromMap(Map<String, dynamic> map) {
    return ChatMessagingModel(
      senderUid: map['senderUid'],
      messageId: map['messageId'],
      roomId: map['roomId'],
    );
  }
}
