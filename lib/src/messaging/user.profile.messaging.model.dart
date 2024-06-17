/// User Profile Messaging Model
class UserProfileMessaging {
  String uid;

  UserProfileMessaging({
    required this.uid,
  });
  factory UserProfileMessaging.fromMap(Map<String, dynamic> map) {
    return UserProfileMessaging(
      uid: map['uid'],
    );
  }
}
