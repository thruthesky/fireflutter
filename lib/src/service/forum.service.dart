import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/src/service/fireflutter_options.dart';

class ForumService {
  static ForumService? _instance;
  static ForumService get instance => _instance ??= ForumService._();

  FirebaseDatabase get db => FirebaseDatabase.instance;

  FireFlutterOptions? options;

  ForumService._() {
    print('---> ForumService constructor');
  }

  DatabaseReference categoryRef(String category) {
    return db.ref('posts').child(category);
  }
}
