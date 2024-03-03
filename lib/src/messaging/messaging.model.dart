import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class MessagingModel {
  static const String postSubscriptions = 'post-subscriptions';

  static String postSubscription(String category) =>
      '$postSubscriptions/$category/$myUid';

  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference userFcmTokensRef = root.child('user-fcm-tokens');
  static Query userTokens(String uid) =>
      userFcmTokensRef.orderByChild('uid').equalTo(uid);
}
