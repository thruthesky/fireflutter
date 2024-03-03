import 'package:fireflutter/fireflutter.dart' as ff;

class UserPrivateModel {
  /// Paths and Refs
  static const String nodeName = 'user-private';

  final String? email;
  final String? phoneNumber;

  UserPrivateModel({
    this.email,
    this.phoneNumber,
  });

  factory UserPrivateModel.fromJson(Map<dynamic, dynamic> json) {
    return UserPrivateModel(
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

  static Future<UserPrivateModel> get() async {
    final data = await ff.get<Map>(
      '$nodeName/${ff.myUid}',
    );
    return UserPrivateModel.fromJson(data ?? {});
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
