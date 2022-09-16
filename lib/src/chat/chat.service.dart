import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ?? (_instance = ChatService());

  /// The user that the signed-in-user chatting with on the chat room.
  /// If signed-in-user leaves the chat room, this value becomes null.
  UserModel? otherUser;

  /// Sends push notification to the other user
  ///
  /// Check if the other user muted on me. If so, don't send the message.
  Future<DocumentReference?> sendPushNotification({
    required String title,
    required String body,
    required String uid,
    required String badge,
  }) async {
    // final s = UserSettings(uid: uid, documentId: 'chat.$uid');
    // print('s.path; ${s.path}, my uid: ${UserService.instance.uid}');

    final doc = await UserSettings(
            uid: uid, documentId: 'chat.${UserService.instance.uid}')
        .get();
    // print(doc);
    if (doc != null) {
      print('The user muted me. Just return.');
      return null;
    }

    return MessagingService.instance.queue({
      'title': title,
      'body': body,
      'uids': uid,
      'badge': badge,
      'type': 'chat',
      'senderUid': UserService.instance.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
