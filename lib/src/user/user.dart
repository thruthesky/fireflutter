import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';

class User {
  static User? _instance;
  static User get instance => _instance ?? (_instance = User());

  UserModel? data;
  String? get displayName => data?.displayName;

  CollectionReference get col => FirebaseFirestore.instance.collection('users');
  DocumentReference get doc => col.doc(FirebaseAuth.instance.currentUser?.uid);

  @Deprecated('Use return User.instance.get(uid);')
  Future<UserModel> getOtherUserDoc(
    String uid, {
    bool reset = false,
  }) async {
    assert(uid != '');

    return User.instance.get(uid);
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  bool get notSignedIn => isAnonymous || auth.currentUser == null;

  bool get signedIn => !notSignedIn;
  bool get isAnonymous => auth.currentUser?.isAnonymous ?? false;

  /// TODO check if the user is admin
  bool get isAdmin => false;

  /// ^ Even if anonymously-sign-in enabled, it still needs to be nullable.
  /// ! To avoid `null check operator` problem in the future.
  String? get uid => auth.currentUser?.uid;

  create() {}
  get([String? uid]) {
    /// TODO return UserModel of the user uid
  }
  Future<void> update(Map<String, dynamic> data) {
    return doc.set({
      ...data,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  delete() {}

  Future<UserModel> blockUser(String uid) async {
    UserModel user = await User.instance.get(uid);

    /// TODO block user by admin
    ///
    // if (user.disabled) throw ERROR_USER_ALREADY_BLOCKED;

    // final res = await FunctionsApi.instance
    //     .request('adminDisableUser', data: {'userUid': uid}, addAuth: true);
    // UserModel u = UserModel.fromJson(res, uid);
    // if (u.disabled) others[uid]!.disabled = u.disabled;
    // return others[uid]!;

    return user;
  }

  static Future<UserModel> unblockUser(String uid) async {
    UserModel user = await User.instance.get(uid);

    /// TODO unblock user by admin
    ///
    // if (!user.disabled) throw ERROR_USER_ALREADY_UNBLOCKED;

    // final res = await FunctionsApi.instance
    //     .request('adminEnableUser', data: {'userUid': uid}, addAuth: true);
    // UserModel u = UserModel.fromJson(res, uid);
    // if (u.disabled == false) others[uid]!.disabled = u.disabled;
    // return others[uid]!;

    return user;
  }
}
