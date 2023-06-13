import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FireFlutter {
  static FireFlutter? _instance;
  static FireFlutter get instance => _instance ??= FireFlutter._();

  FireFlutterOptions? _options;
  FireFlutterOptions get options => _options!;

  FireFlutter._() {
    print('---> FireFlutter constructor');
    UserService.listenCurrentUser();
  }

  init(FireFlutterOptions options) {
    print('---> FireFlutter init');
    this._options = options;
  }

  /// Display error
  error(BuildContext context, dynamic e) {
    late final String message;

    if (e is String) {
      message = e;
    } else if (e is Map && e['code'] != null) {
      message = '${e['code']} - ${e['message'] ?? ''}';
    } else if (e is FirebaseAuthException) {
      message = e.message!;
    } else {
      message = e.toString();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 13),
      ),
    );
  }

  info(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 13),
      ),
    );
  }
}
