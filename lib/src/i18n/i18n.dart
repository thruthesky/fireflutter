import 'package:json_annotation/json_annotation.dart';

part 'i18n.g.dart';

@JsonSerializable()
class I18nTexts {
  String loginFirstTitle;
  String loginFirstMessage;
  String loginFirstToUseCompleteFunctionality;
  String noOfChatRooms;
  String roomMenu;
  String chatSingleRoomCreateDialog;
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
  String blocked;
  String unblock;
  String blockMessage;
  String unblockMessage;
  String alreadyBlockedTitle;
  String alreadyBlockedMessage;
  String disabled;
  String disabledMessage;
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

  String howAreYouToday;
  String stateMessage;

  String share;
  String home;
  String profile;
  String createChatRoom;
  String views;

  /// activity_log user
  String startAppLog;
  String signinLog;
  String signoutLog;
  String resignLog;
  String createUserLog;
  String updateUserLog;
  String roomOpenLog;
  String likedUserLog;
  String unlikedUserLog;
  String followedUserLog;
  String unfollowedUserLog;
  String viewProfileUserLog;

  /// activity_log post
  String createPostLog;
  String updatePostLog;
  String deletePostLog;
  String likedPostLog;
  String unlikedPostLog;

  /// activity_log comment
  String createCommentLog;
  String updateCommentLog;
  String deleteCommentLog;
  String likedCommentLog;
  String unlikedCommentLog;

  String adminBackFillWarning;
  String categoryUpdated;
  String categoryUpdatedMessage;

  I18nTexts({
    this.loginFirstTitle = 'Login first',
    this.loginFirstMessage = 'Please login first.',
    this.noOfChatRooms = 'No chat rooms, yet. Create one!',
    this.roomMenu = 'Chat Room Menu',
    this.chatSingleRoomCreateDialog = 'New chat room created. Enjoy chatting!',
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
    this.blocked = 'Blocked',
    this.unblock = "Unblock",
    this.blockMessage = "Blocked",
    this.unblockMessage = "Unblocked",
    this.alreadyBlockedTitle = "Already blocked",
    this.alreadyBlockedMessage = "You have blocked this user already.",
    this.disabled = "Disabled",
    this.disabledMessage = "You are disabled.",
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
    this.readLess = "read less",
    this.readMore = "read more",
    this.noOfLikes = "Likes #no",
    this.howAreYouToday = "How are you today?",
    this.stateMessage = 'State Message',
    this.share = "Share",
    this.loginFirstToUseCompleteFunctionality = "Login first to use the complete functionality.",
    this.home = "Home",
    this.profile = "Profile",
    this.createChatRoom = "Create chat room",
    this.views = "Views",

    /// activity_log user
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
    this.roomOpenLog = "#a opened a chat room",

    /// activity_log post
    this.createPostLog = "#a created a post",
    this.updatePostLog = "#a updated a post",
    this.deletePostLog = "#a deleted a post",
    this.likedPostLog = "#a liked a post",
    this.unlikedPostLog = "#a unliked a post",

    /// activity_log comment
    this.createCommentLog = "#a created a comment",
    this.updateCommentLog = "#a updated a comment",
    this.deleteCommentLog = "#a deleted a comment",
    this.likedCommentLog = "#a liked a comment",
    this.unlikedCommentLog = "#a unliked a comment",
    this.adminBackFillWarning = 'This will reset all data in Supabase.',
    this.categoryUpdated = 'Category updated.',
    this.categoryUpdatedMessage = 'Category has been updated',
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
