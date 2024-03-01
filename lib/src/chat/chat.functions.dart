import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';

const String chatRoomDivider = '---';

// /// 채팅방 ID 에서, 1:1 채팅방인지 확인한다.
isSingleChatRoom(String roomId) {
  final splits = roomId.split(chatRoomDivider);
  return splits.length == 2 && splits[0].isNotEmpty && splits[1].isNotEmpty;
}

// /// 채팅방 ID 에서 그룹 채팅방 ID 인지 확인한다.
// isGroupChat(String roomId) => roomId.split('-').length == 1;

/// 1:1 채팅방 ID 에서 다른 사용자의 uid 를 리턴한다.
///
/// 그룹 채팅방 ID 이면, null 을 리턴한다.
///
/// 주의, 자기 자신과 대화를 할 수 있으니, 그 경우에는 자기 자신의 uid 를 리턴한다.
String? getOtherUserUidFromRoomId(String roomId) {
  final splits = roomId.split(chatRoomDivider);
  if (splits.length != 2) {
    return null;
  }
  for (final uid in splits) {
    if (uid != FirebaseAuth.instance.currentUser!.uid) {
      return uid;
    }
  }
  return FirebaseAuth.instance.currentUser!.uid;
}

/// 일대일 채팅방 ID 를 만든다.
///
/// 로그인 사용자의 uid 와 [otherUserUid] 를 정렬해서 합친다.
String singleChatRoomId(String otherUserUid) {
  if (myUid == null) {
    throw Exception('chat.function.dart::singleChatRoomId() -> Login first');
  }
  final uids = [FirebaseAuth.instance.currentUser!.uid, otherUserUid];
  uids.sort();
  return uids.join(chatRoomDivider);
}
