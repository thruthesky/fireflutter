/// User Messaging Model
class UserMessaging {
  String uid;

  UserMessaging({
    required this.uid,
  });
  factory UserMessaging.fromMap(Map<String, dynamic> map) {
    return UserMessaging(
      uid: map['uid'],
    );
  }
}
