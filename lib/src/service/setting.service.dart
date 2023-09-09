// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:fireflutter/fireflutter.dart';

// class SettingService with FirebaseHelper {
//   static SettingService? _instance;
//   static SettingService get instance => _instance ?? SettingService._();

//   SettingService._();

//   DatabaseReference ref(String path, {String? uid}) =>
//       rtdb.ref('settings').child(uid ?? FirebaseAuth.instance.currentUser!.uid).child(path);

//   /// Get a node
//   ///
//   /// Note that, [FirebaseDatabase.instance.get] has a bug. So [once] is being
//   /// used.
//   ///
//   /// [uid] if [uid] is not given, it will get node under the current user.
//   ///
//   /// [path] is the path of the node.
//   ///
//   /// Example: below will get the snapshot of /settings/abc/path/to/node
//   /// ```
//   /// final snapshot = await get('path/to/node', uid: 'abc');
//   /// ```
//   ///
//   Future<DataSnapshot> get(String path, {String? uid}) async {
//     final event = await ref(path, uid: uid).once(DatabaseEventType.value);
//     return event.snapshot;
//   }

//   /// Toogle a node
//   ///
//   /// If the node of the [path] does not exist, create it and return true.
//   /// if the node exists, then remove it and return false.
//   Future<bool> toggle(String path, {String? uid}) async {
//     final snapshot = await get(path, uid: uid);

//     if (snapshot.exists) {
//       await ref(path, uid: uid).remove();
//       return false;
//     } else {
//       await ref(path, uid: uid).set(true);
//       return true;
//     }
//   }
// }
