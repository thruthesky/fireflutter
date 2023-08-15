class I18N {
  UserTranslations user = UserTranslations();
  ChatTranslations chat = ChatTranslations();
}

class UserTranslations {
  String loginFirst = 'Please login first';
}

class ChatTranslations {
  String noChatRooms = 'No chat rooms';
}

final tr = I18N();
