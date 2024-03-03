/// User Messaging Model
class UserMessagingModel {
  String uid;

  UserMessagingModel({
    required this.uid,
  });
  factory UserMessagingModel.fromMap(Map<String, dynamic> map) {
    return UserMessagingModel(
      uid: map['uid'],
    );
  }
}
