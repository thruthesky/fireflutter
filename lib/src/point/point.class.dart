import 'package:firebase_database/firebase_database.dart';

class Point {
  static DatabaseReference get pointsRef =>
      FirebaseDatabase.instance.ref('point');
  static DatabaseReference userPointDoc(String uid) => pointsRef.child(uid);

  /// Get user's current point.
  ///
  static Future<int> getUserPoint(String uid) async {
    final pointSnap = await userPointDoc(uid).child('point').get();
    if (pointSnap.exists) {
      final point = pointSnap.value as int?;
      return point ?? 0;
    } else {
      return 0;
    }
  }
}
