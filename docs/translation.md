
# Translation

The texts used in FireFlutter are defined in `lib/i18n/i18nt.dart`.

By default, it supports English but you can overwrite the texts to whatever language.

Below show you how to customize texts in your language. If you want to support multi-languages, you may overwrite the texts on device language.

```dart
TextService.instance.texts = I18nTexts({
    this.loginFirstTitle = 'Login first',
    this.loginFirstMessage = 'Please login first.',
    this.noOfChatRooms = 'No chat rooms, yet. Create one!',
    this.roomMenu = 'Chat Room Menu',
    this.chatRoomCreateDialog =
        'New chat room created. You can invite more users. Enjoy chatting!',
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
    this.loginFirstToUseCompleteFunctionality =
        "Login first to use the complete functionality.",
    this.home = "Home",
    this.profile = "Profile",
    this.createChatRoom = "Create chat room",
  });
```

You can use the language like below,

```dart
 Text(
  noOfLikes == null
      ? tr.like
      : tr.likes.replaceAll(
          '#no', noOfLikes.length.toString()),
 ),
```
