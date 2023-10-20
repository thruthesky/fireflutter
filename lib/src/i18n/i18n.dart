import 'package:json_annotation/json_annotation.dart';

part 'i18n.g.dart';

@JsonSerializable()
class I18nTexts {
  String loginFirstTitle;
  String loginFirstMessage;
  String loginFirstToUseCompleteFunctionality;
  String noOfChatRooms;
  String roomMenu;
  String chatRoomCreateDialog;
  String chooseUploadFrom;
  String noCategory;
  String noPost;
  String noComment;
  String noReply;
  String title;
  String content;
  String postCreate;
  String postUpdate;
  String titleRequired;
  String contentRequired;
  String dismiss;
  String yes;
  String no;
  String ok;
  String edit;
  String delete;
  String cancel;
  String reply;
  String like;
  String likes;
  String favorite;
  String unfavorite;
  String favoriteMessage;
  String unfavoriteMessage;
  String chat;
  String block;
  String unblock;
  String blockMessage;
  String unblockMessage;
  String alreadyBlockedTitle;
  String alreadyBlockedMessage;
  String report;
  String alreadyReportedTitle;
  String alreadyReportedMessage;
  String noChatRooms;
  String follow;
  String unfollow;
  String whoFollowedWho;
  String followMessage;
  String unfollowMessage;
  String noStateMessage;

  String copyLink;
  String copyLinkMessage;

  String showMoreComments;

  String askOpenLink;
  String readLess;
  String readMore;

  String noOfLikes;

  String share;
  String home;
  String profile;
  String createChatRoom;

  String startAppLog;
  String signinLog;
  String signoutLog;
  String resignLog;
  String createUserLog;
  String updateUserLog;
  String likedUserLog;
  String unlikedUserLog;
  String followedUserLog;
  String unfollowedUserLog;
  String viewProfileUserLog;

  I18nTexts({
    this.loginFirstTitle = 'Login first',
    this.loginFirstMessage = 'Please login first.',
    this.noOfChatRooms = 'No chat rooms, yet. Create one!',
    this.roomMenu = 'Chat Room Menu',
    this.chatRoomCreateDialog = 'New chat room created. You can invite more users. Enjoy chatting!',
    this.chooseUploadFrom = "Choose upload from...",
    this.noCategory = "No category, yet. Create one!",
    this.noPost = "No post yet. Create one!",
    this.noComment = "No comment, yet. Create one!",
    this.noReply = "No reply",
    this.title = "Title",
    this.content = "Content",
    this.postCreate = "Post created",
    this.postUpdate = "Post updated",
    this.titleRequired = "Title is required",
    this.contentRequired = "Content is required",
    this.dismiss = "Dismiss",
    this.yes = "Yes",
    this.no = "No",
    this.ok = "OK",
    this.edit = 'Edit',
    this.delete = 'Delete',
    this.cancel = "Cancel",
    this.reply = "Reply",
    this.like = "Like",
    this.likes = "Likes(#no)",
    this.favorite = "Favorite",
    this.unfavorite = "Unfavorite",
    this.favoriteMessage = "Added to favorite",
    this.unfavoriteMessage = "Removed from favorite",
    this.chat = "Chat",
    this.block = "Block",
    this.unblock = "Unblock",
    this.blockMessage = "Blocked",
    this.unblockMessage = "Unblocked",
    this.alreadyBlockedTitle = "Already blocked",
    this.alreadyBlockedMessage = "You have blocked this user already.",
    this.report = "Report",
    this.alreadyReportedTitle = "Already reported",
    this.alreadyReportedMessage = "You have reported this #type already.",
    this.noChatRooms = "No chat rooms, yet. Create one!",
    this.follow = "Follow",
    this.unfollow = "Unfollow",
    this.whoFollowedWho = "#a followed #b",
    this.followMessage = "You are following this user.",
    this.unfollowMessage = "You are not following this user anymore.",
    this.noStateMessage = "No state message, yet. Create one!",
    this.copyLink = "Copy Link",
    this.copyLinkMessage = "Link copied to clipboard",
    this.showMoreComments = "Show #no comments",
    this.askOpenLink = "Do you want to open this link?",
    this.readLess = "Read less",
    this.readMore = "Read more",
    this.noOfLikes = "Likes #no",
    this.share = "Share",
    this.loginFirstToUseCompleteFunctionality = "Login first to use the complete functionality.",
    this.home = "Home",
    this.profile = "Profile",
    this.createChatRoom = "Create chat room",

    /// activity_log
    this.startAppLog = "#a started the app",
    this.signinLog = "#a signed in",
    this.signoutLog = "#a signed out",
    this.resignLog = "#a resigned",
    this.createUserLog = "#a created an account",
    this.updateUserLog = "#a updated profile",
    this.likedUserLog = "#a liked #b",
    this.unlikedUserLog = "#a unliked #b",
    this.followedUserLog = "#a followed #b",
    this.unfollowedUserLog = "#a unfollowed #b",
    this.viewProfileUserLog = "#a viewed #b's profile",
  });

  factory I18nTexts.fromJson(Map<String, dynamic> json) => _$I18nTextsFromJson(json);

  Map<String, dynamic> toJson() => _$I18nTextsToJson(this);
}

class TextService {
  static TextService? _instance;
  static TextService get instance => _instance ??= TextService._();

  TextService._();

  I18nTexts texts = I18nTexts();
  I18nTexts get tr => texts;
}

I18nTexts get tr => TextService.instance.tr;
