/// Code class contains all the error codes used in the package.
///
///
class Code {
  static const notLoggedIn = 'User is not logged in.';
  static const documentNotExist = 'User document does not exist.';
  static const documentAlreadyExists = 'User document already exists.';
  static const roomIsFull = 'The chat room is already full.';
  static const singleChatRoomCannotInvite =
      'The chat room is not a group chat. Cannot invite another user.';
  static const userAlreadyInRoom = 'The user is already a member of the room.';
}
