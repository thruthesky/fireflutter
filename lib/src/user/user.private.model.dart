import 'package:fireflutter/fireflutter.dart' as ff;

class UserPrivate {
  /// Paths and Refs
  static const String nodeName = 'user-private';

  final String? email;
  final String? phoneNumber;

  UserPrivate({
    this.email,
    this.phoneNumber,
  });

  factory UserPrivate.fromJson(Map<dynamic, dynamic> json) {
    return UserPrivate(
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  static Future<UserPrivate> get() async {
    final data = await ff.get<Map>(
      '$nodeName/${ff.myUid}',
    );
    return UserPrivate.fromJson(data ?? {});
  }

  static Future<void> update({
    String? email,
    String? phoneNumber,
  }) async {
    final data = {
      if (email != null) 'email': email,
      if (email == "") 'email': null,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (phoneNumber == "") 'phoneNumber': null,
    };
    if (data.isEmpty) {
      return;
    }

    await ff.update(
      '$nodeName/${ff.my!.uid}',
      data,
    );
  }
}
