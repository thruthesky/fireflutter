import 'package:firebase_database/firebase_database.dart';

class AdminModel {
  /// Paths and Refs
  static const String path = 'admins';
  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference ref = root.child(path);
}
