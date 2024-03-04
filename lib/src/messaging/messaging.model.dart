import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class MessagingModel {
  static const String userFcmTokens = 'user-fcm-tokens';
  static const String postSubscriptions = 'post-subscriptions';

  static DatabaseReference rootRef = FirebaseDatabase.instance.ref();

  @Deprecated('Use postSubscriptionRef instead')
  static String postSubscription(String category) =>
      '$postSubscriptions/$category/$myUid';

  static DatabaseReference postSubscriptionRef(String category) =>
      rootRef.child('$postSubscriptions/$category/$myUid');

  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference userFcmTokensRef = root.child(userFcmTokens);
  static Query userTokens(String uid) =>
      userFcmTokensRef.orderByChild('uid').equalTo(uid);
}
