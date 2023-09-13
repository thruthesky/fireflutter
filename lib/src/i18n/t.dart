class I18N {
  UserTranslations user = UserTranslations();
  ChatTranslations chat = ChatTranslations();
  UploadTranslations upload = UploadTranslations();
  CategoryTranslations category = CategoryTranslations();
  PostTranslations post = PostTranslations();
  CommentTranslations comment = CommentTranslations();
  FormTranslations form = FormTranslations();
  ToastTranslations toast = ToastTranslations();
  ConfirmTranslations confirm = ConfirmTranslations();
  AlertTranslations alert = AlertTranslations();
  PromptTranslations prompt = PromptTranslations();
  MenuTranslations menu = MenuTranslations();
}

class UserTranslations {
  String loginFirstTitle = 'Login first';
  String loginFirstMessage = 'Please login first.';
}

class ChatTranslations {
  String noChatRooms = 'No chat rooms';
  String roomMenu = 'Chat Room Menu';
  String chatRoomCreateDialog =
      'New chat room created. You can invite more users. Enjoy chatting!';
}

class UploadTranslations {
  String chooseFrom = "Choose upload from...";
}

class CategoryTranslations {
  String noCategory = 'No category';
}

class PostTranslations {
  String noPost = 'No post';
}

class CommentTranslations {
  String noComment = 'No comment yet.';
  String noReply = 'No reply yet.';
}

class FormTranslations {
  String title = 'Title';
  String content = 'Content';
  String postCreate = 'CREATE';
  String postUpdate = 'UPDATE';
  String titleRequired = 'Title is required';
  String contentRequired = 'Content is required';
}

class ToastTranslations {
  String dismiss = 'Dismiss';
}

class ConfirmTranslations {
  String yes = 'Yes';
  String no = 'No';
}

class AlertTranslations {
  String ok = "OK";
}

class PromptTranslations {
  String ok = "OK";
  String cancel = "Cancel";
}

class MenuTranslations {
  String like = "Like";
  String likes = "#no Likes";
  String favorite = "Favorite";
  String unfavorite = "Unfavorite";
  String favoriteMessage = "You have favorited this user.";
  String unfavoriteMessage = "You have unfavorited this user.";
  String chat = "Chat";
  String block = "Block";
  String unblock = "Unblock";
  String blockMessage = "This user is blocked.";
  String unblockMessage = "This user is unblocked.";
  String alreadyBlockedTitle = "Already blocked";
  String alreadyBlockedMessage = "This user is already blocked.";
  String report = "Report";
  String alreadyReportedTitle = "Already reported";
  String alreadyReportedMessage = "You have reported this #type already.";
}

final tr = I18N();
