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
  String loadButtonDialog;
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
  String liked;
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
  String noBlockedUser;
  String noBlockedUserYet;
  String messageCommingFromBlockedUser;
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
  String noFollower;
  String noFollowerYet;
  String noFollowing;
  String noFollowingYet;
  String usersIFollow;
  String searchResult;
  String searchUser;
  String noStateMessage;

  String deletingPost;
  String deletingPostConfirmation;

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
  String users;
  String singleChat;
  String groupChat;
  String openRoom;
  String privateRoom;
  String feedCategory;
  String createCategory;
  String categoryName;
  String feedForumn;
  String name;
  String description;
  String defaultChannel;
  String defaultSound;
  String andriod;
  String inputTokens;
  String inputTokensHint;
  String chooseUser;
  String searchByUid;
  String noMessageYet;

  /// activity log appbar titile
  String titleStatistic;
  String titleReportList;
  String titleCategoryList;
  String titleChatRoomList;
  String titleActivityLog;
  String titleNotificationSetting;
  String titleAdminFileList;
  String titlePushNotification;

  /// activity_log user
  String startAppLog;
  String signinLog;
  String signoutLog;
  String resignLog;
  String createUserLog;
  String updateUserLog;
  String roomOpenLog;
  String roomOpenGroupLog;
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

  /// label string
  String labelAll;
  String labelImages;
  String labelVideos;
  String labelOthers;
  String labelUserSearch;
  String labelSearch;
  String labelUser;
  String labelPost;
  String labelComment;
  String labelView;
  String categoryPermanentId;
  String categoryId;
  String channelIdAndriod;
  String labelChooseTarget;
  String labelRoomId;
  String labelLastActivity;
  String labelRoomType;
  String labelTopic;
  String labelPlatform;
  String labelTokens;
  String labelSelectPlatform;
  String labelTitle;
  String labelBody;
  String labelSound;
  String labelInputPostId;
  String labelInputAnyText;
  String labelNotificationGuide;
  String sound;
  String labelUserList;
  String labelTokenList;
  String labelNotificationType;

  /// button string
  String deleteComment;
  String deletePost;
  String markAsResolve;
  String disableUser;
  String update;
  String create;
  String sendPushMessage;

  // notification setting
  String notificationSettingNewComments;
  String notificationSettingProfileVisited;
  String notificationSettingProfileLiked;
  String notificationSettingPostLiked;
  String notificationSettingCommentLiked;
  String pushNotificationUserHint;
  String pushNotificationTokenHint;

  String selectCategory;

  I18nTexts({
    this.loginFirstTitle = 'Login first',
    this.loginFirstMessage = 'Please login first.',
    this.noOfChatRooms = 'No chat rooms, yet. Create one!',
    this.roomMenu = 'Chat Room Menu',
    this.chatSingleRoomCreateDialog = 'New chat room created. Enjoy chatting!',
    this.chatRoomCreateDialog = 'New chat room created. You can invite more users. Enjoy chatting!',
    this.loadButtonDialog = 'Click the load botton to update the title and body from the post id',
    this.chooseUploadFrom = "Choose upload from...",
    this.noCategory = "No category, yet. Create one!",
    this.noPost = "No post yet. Create one!",
    this.selectCategory = 'Select Category',
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
    this.liked = "Liked",
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
    this.noBlockedUser = "No blocked user.",
    this.noBlockedUserYet = "You haven't blocked any user yet.",
    this.messageCommingFromBlockedUser = 'This message is comming from a blocked user',
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
    this.noFollower = "No follower, yet.",
    this.noFollowerYet = "Have not been followed by anyone, yet.",
    this.noFollowing = "Have not followed anyone, yet.",
    this.noFollowingYet = "Have not followed anyone, yet.",
    this.usersIFollow = "Users I follow",
    this.searchResult = "Search result",
    this.searchUser = "Search user",
    this.noStateMessage = "No state message, yet. Create one!",
    this.deletingPost = "Deleting post",
    this.deletingPostConfirmation = "Are you sure you want to delete this post?",
    this.copyLink = "Copy Link",
    this.copyLinkMessage = "Link copied to clipboard",
    this.showMoreComments = "Show #no comments",
    this.askOpenLink = "Do you want to open this link?",
    this.readLess = "read less",
    this.readMore = "read more",
    this.noOfLikes = "#no likes",
    this.howAreYouToday = "How are you today?",
    this.stateMessage = 'State Message',
    this.share = "Share",
    this.loginFirstToUseCompleteFunctionality = "Login first to use the complete functionality.",
    this.home = "Home",
    this.profile = "Profile",
    this.createChatRoom = "Create chat room",
    this.views = "Views",
    this.users = "Users",
    this.feedCategory = "Feed Category",
    this.feedForumn = "Feed Forum",
    this.name = "Name",
    this.description = "Description",
    this.createCategory = "Create Category",
    this.singleChat = "1:1 Chat",
    this.groupChat = "Group Chat",
    this.openRoom = "Open Room",
    this.privateRoom = "Private Room",
    this.defaultChannel = "Default Channel",
    this.defaultSound = "Default",
    this.andriod = "Andriod",
    this.sound = "Sound",
    this.inputTokens = "Input token's",
    this.inputTokensHint = "Multipule token must be separated by comma (,)",
    this.chooseUser = "Choose user",
    this.searchByUid = "Search by uid",
    this.noMessageYet = "No message yet",

    /// activity log appbar titile
    this.titleStatistic = "Admin Statistics",
    this.titleReportList = "Admin Report List",
    this.titleCategoryList = "Category List",
    this.titleChatRoomList = "Admin Chat Room List",
    this.titleActivityLog = "Activity Logs",
    this.titleNotificationSetting = "Notification Settings",
    this.titleAdminFileList = "Admin File List",
    this.titlePushNotification = "Push Notification",

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
    this.roomOpenLog = "#a opened a chat room with #b",
    this.roomOpenGroupLog = "#a opened a chat group id #b",

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

    /// label string
    this.labelAll = "all",
    this.labelImages = "Images",
    this.labelVideos = "Videos",
    this.labelOthers = "Others",
    this.labelUserSearch = "User Search",
    this.labelSearch = "Search",
    this.labelUser = "user",
    this.labelPost = "post",
    this.labelComment = "comment",
    this.labelView = "View",
    this.categoryName = "Category Name",
    this.categoryId = 'Category ID',
    this.categoryPermanentId = "Category (Permanent Id)",
    this.channelIdAndriod = "Channel ID (Andriod)",
    this.labelChooseTarget = "Choose Target",
    this.labelRoomId = "Room ID",
    this.labelLastActivity = "Last Activity",
    this.labelRoomType = "Room Type",
    this.labelTopic = "Topic",
    this.labelPlatform = "Platform",
    this.labelTokens = "Tokens",
    this.labelSelectPlatform = "Select Platform",
    this.labelTitle = "Title",
    this.labelBody = "Body",
    this.labelSound = "Sound",
    this.labelInputPostId = "Input #a ID",
    this.labelInputAnyText = "Input the #a text",
    this.labelNotificationGuide = "Push notification guideline",
    this.labelUserList = "User list",
    this.labelTokenList = "Token list",
    this.labelNotificationType = "Select notification type",

    /// button
    this.deleteComment = "Delete Comment",
    this.disableUser = "Disable User",
    this.markAsResolve = "Mark as Resolve",
    this.deletePost = "Delete Post",
    this.update = "Update",
    this.create = "Create",
    this.sendPushMessage = "Send Push Message",

    // notification setting
    this.notificationSettingNewComments = 'Receive notifications of new comments under my posts and comments',
    this.notificationSettingProfileVisited = 'Receive notifications on profile visited',
    this.notificationSettingProfileLiked = 'Receive notifications on profile liked',
    this.notificationSettingPostLiked = 'Receive notifications on post liked',
    this.notificationSettingCommentLiked = 'Receive notifications on comment liked',
    this.pushNotificationUserHint = "Choose users to send push notification",
    this.pushNotificationTokenHint = "Choose users to get tokens and  send push notification.",
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
