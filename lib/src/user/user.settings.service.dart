import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:rxdart/subjects.dart';

///
class UserSettingsService {
  static UserSettingsService? _instance;
  static UserSettingsService get instance =>
      _instance ?? (_instance = UserSettingsService());

  StreamSubscription? userSettingsDocumentSubscription;
  BehaviorSubject userSettingsChange = BehaviorSubject.seeded(UserModel());

  UserSettingsModel? settings;
  CollectionReference get userSettingsCol => FirebaseFirestore.instance
      .collection('users')
      .doc(UserService.instance.uid!)
      .collection('user-settings');

  observeUserSettingsDoc() {
    // userSettingsDocumentSubscription?.cancel();
    // userSettingsDocumentSubscription =
    //     doc.snapshots().listen((DocumentSnapshot snapshot) async {
    //   if (snapshot.exists == false) {
    //     log('---> User document not exits in observeUserDoc.');
    //   }
    //   user = UserModel.fromSnapshot(snapshot);
    //   log('----> observeUserDoc and update event with; $user');
    //   userChange.add(user);
    // });
  }

  /// 로그아웃을 할 때 호출되며, 사용자 모델(user)을 초기화하고, listening 해제하고, 이벤트를 날린다.
  unobserveUserDoc() {
    // userDocumentSubscription?.cancel();
    // user = UserModel();
    // userChange.add(user);
  }

  Future<void> update(String field, dynamic value) async {
    userSettingsCol.doc(field).set(value, SetOptions(merge: true));
  }

  // Map<String, UserModel> userDocumentContainer = {};
  // Future<UserModel> get() async {
  //   final snapshot = await userSettingsCol.get();
  //   userDocumentContainer[uid] = UserSettingsModel.fromSnapshot(snapshot);
  //   return userDocumentContainer[uid]!;
  // }

  // /// 문서가 존재하지 않으면 생성을 한다.
  // Future<void> update(Map<String, dynamic> data) {
  //   return doc.set({
  //     ...data,
  //     'updatedAt': Timestamp.now(),
  //   }, SetOptions(merge: true));
  // }

}
