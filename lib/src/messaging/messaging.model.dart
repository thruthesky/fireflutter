import 'package:fireflutter/fireflutter.dart';

class MessagingModel {
  static const String postSubscriptions = 'post-subscriptions';

  static String postSubscription(String category) =>
      '$postSubscriptions/$category/$myUid';
}
