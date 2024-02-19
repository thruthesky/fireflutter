import 'package:fireship/fireship.dart' as fireship;
import 'package:fireship/fireship.defines.dart';

class UserPrivateModel {
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
    final data = await fireship.get<Map>(
      '${Folder.userPrivate}/${fireship.my!.uid}',
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

    await fireship.update(
      '${Folder.userPrivate}/${fireship.my!.uid}',
      data,
    );
  }
}
