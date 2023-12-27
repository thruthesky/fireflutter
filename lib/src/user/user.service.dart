import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class UserService {
  static late final UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  UserModel? user;
  final rtdb = FirebaseDatabase.instance.ref();
  DatabaseReference get userRef => rtdb.child('users');

  StreamSubscription? userNodeSubscription;

  UserService._() {
    print('--> UserService._()');
  }

  init() {
    print('--> UserService.init()');
    listenUser();
  }

  listenUser() {
    print('--> UserService.listenUser()');
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      print('--> UserService.listenUser() FirebaseAuth.instance.authStateChanges()');
      if (user == null) {
        this.user = null;
        return;
      }
      userNodeSubscription?.cancel();
      userNodeSubscription = userRef.child(user.uid).onValue.listen((event) {
        print('--> UserService.listenUser() userRef.child(user.uid).onValue.listen()');
        final json = event.snapshot.value as Map<String, dynamic>;
        this.user = UserModel.fromJson(json);
      });
    });
  }
}
