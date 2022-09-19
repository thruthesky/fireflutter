/// Chat room ID
///
/// - Return chat room id of login user and the other user.
/// - The location of chat room is at `/rooms/[ID]`.
/// - Chat room ID is composited with login user UID and other user UID by alphabetic order.
///   - If myLoginId = 3 and otherUserLoginId = 4, then the result is "3-4".
///   - If myLoginId = 321 and otherUserLoginId = 1234, then the result is "1234-321"
String getChatRoomDocumentId(String myLoginId, String otherUserLoginId) {
  return myLoginId.compareTo(otherUserLoginId) < 0
      ? "${myLoginId}__$otherUserLoginId"
      : "${otherUserLoginId}__$myLoginId";
}
