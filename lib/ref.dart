import 'package:firebase_database/firebase_database.dart';

class Ref {
  Ref._();

  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference users = root.child('users');
}
