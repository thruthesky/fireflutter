class I18N {
  UserTranslations user = UserTranslations();
  ChatTranslations chat = ChatTranslations();
  CategoryTranslations category = CategoryTranslations();
}

class UserTranslations {
  String loginFirst = 'Please login first';
}

class ChatTranslations {
  String noChatRooms = 'No chat rooms';
  String roomMenu = 'Chat Room Menu';
}

class CategoryTranslations {
  String noCategory = 'No category';
}

final tr = I18N();
