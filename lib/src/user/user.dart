class User {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
    );
  }
}
