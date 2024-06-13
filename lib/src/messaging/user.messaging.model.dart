/// User Messaging Model
class UserMessaging {
  String receiverUid;
  String senderUid;

  UserMessaging({
    required this.senderUid,
    required this.receiverUid,
  });
  factory UserMessaging.fromMap(Map<String, dynamic> map) {
    return UserMessaging(
      senderUid: map['senderUid'],
      receiverUid: map['receiverUid'],
    );
  }
}
