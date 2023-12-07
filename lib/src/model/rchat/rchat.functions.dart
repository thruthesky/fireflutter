import 'package:fireflutter/fireflutter.dart';

/// 채팅방 ID 에서, 1:1 채팅방인지 확인한다.
isSingleChat(String roomId) => roomId.split('-').length == 2;

/// 채팅방 ID 에서 그룹 채팅방 ID 인지 확인한다.
isGroupChat(String roomId) => roomId.split('-').length == 1;

/// 1:1 채팅방 ID 에서 다른 사용자의 uid 를 리턴한다.
///
/// 주의, 자기 자신이랑 대화 할 때에는 자신의 UID 를 리턴한다.
otherUidFromRoomId(String roomId) {
  return roomId.split('-').firstWhere((uid) => uid != myUid, orElse: () => myUid!);
}
