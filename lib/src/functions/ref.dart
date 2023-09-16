import 'package:fireflutter/fireflutter.dart';

/// Returns a string of database path to the login user's block list.
///
/// [otherUid] is the uid of the user to be blocked or unblocked.
/// If [otherUid] is null or empty, it returns the path to the login user's block list.
String pathBlock(String? otherUid) {
  if (otherUid == null || otherUid.isEmpty) {
    return 'blocks/$myUid';
  } else {
    return 'blocks/$myUid/$otherUid';
  }
}
