class I18N {
  UserTranslations user = UserTranslations();
  ChatTranslations chat = ChatTranslations();
  UploadTranslations upload = UploadTranslations();
}

class UserTranslations {
  String loginFirst = 'Please login first';
}

class ChatTranslations {
  String noChatRooms = 'No chat rooms';
  String roomMenu = 'Chat Room Menu';
}

class UploadTranslations {
  String chooseFrom = "Choose upload from...";
}

final tr = I18N();
