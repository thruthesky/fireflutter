class I18N {
  UserTranslations user = UserTranslations();
  ChatTranslations chat = ChatTranslations();
}

class UserTranslations {
  String loginFirst = 'Please login first';
}

class ChatTranslations {
  String noChatRooms = 'No chat rooms';
  String roomMenu = 'Chat Room Menu';
}

final tr = I18N();
