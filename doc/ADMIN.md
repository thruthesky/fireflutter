# Table of Contents {ignore=true}


<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->
<!-- [toc] -->
- [Overview](#overview)
- [Admin Service](#admin-service)
- [Admin Widgets](#admin-widgets)
  - [Opening admin dashboard](#opening-admin-dashboard)
  - [AdminUserListView](#adminuserlistview)
  - [Updating auth custom claims](#updating-auth-custom-claims)
  - [Disable user](#disable-user)

<!-- /code_chunk_output -->

# Admin 

## Overview

FireFlutter has an Admin Builders and Widgets so you don't have to create your own and deploy them at once. This helps for User Management and more.

## Admin Service

You can access some features using the `AdminService.instance`. Here are few example of how to use `AdminService`

```dart
final service = AdminService.instance;

/// Display the Chat Room details
/// [Room] room is required
service.showChatRoomDetails(context, room: room); // returns Widget

/// Display a screen where you can see all post and open it
/// onTap is optional
service.showChoosePostScreen(context, onTap: (post){ // returns a Scaffold widget
  // your code here
});
```

## Admin Widgets
Here are the Admin widgets that you can use on your app.

### Opening admin dashboard

To open admin dashboard, call `AdminService.instance.showDashboard()`.

```dart
AdminService.instance.showDashboard(context);
```

Or you may want to open with your own code like below

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (c) => const AdminDashboardScreen()),
);
```

### AdminUserListView
To display all users on Admin's side you can use this widget `AdminUserListView`

```dart
buttonBuilder(
  'Show Admin User List View',
  () => showDialog(
    context: context,
    builder: (cnx) => const Dialog(
      child: AdminUserListView(),
    ),
  ),
),
```
<!-- TODO: Ask Sir Song if this is outdated -->
### Updating auth custom claims

- Required properties

  - `{ command: 'update_custom_claims' }` - the command.
  - `{ uid: 'xxx' }` - the user's uid that the claims will be applied to.
  - `{ claims: { key: value, xxx: xxx, ... } }` - other keys and values for the claims.

- example of document creation for update_custom claims

![Image Link](https://github.com/thruthesky/easy-extension/blob/main/docs/command-update_custom_claims_input.jpg?raw=true "This is image title")

- Response
  - `{ config: ... }` - the configuration of the extension
  - `{ response: { status: 'success' } }` - success respones
  - `{ response: { timestamp: xxxx } }` - the time that the executino had finished.
  - `{ response: { claims: { ..., ... } } }` - the claims that the user currently has. Not the claims that were requested for updating.

![Image Link](https://github.com/thruthesky/easy-extension/blob/main/docs/command-update_custom_claims_output.jpg?raw=true "This is image title")

- `SYNC_CUSTOM_CLAIMS` option only works with `update_custom_claims` command.
  - When it is set to `yes`, the claims of the user will be set to user's document.
  - By knowing user's custom claims,
    - the app can know that if the user is admin or not.
      - If the user is admin, then the app can show admin menu to the user.
    - Security rules can work better.

### Disable user

- Disabling a user means that they can't sign in anymore, nor refresh their ID token. In practice this means that within an hour of disabling the user they can no longer have a request.auth.uid in your security rules.

  - If you wish to block the user immediately, I recommend to run another command. Running `update_custom_claims` comand with `{ disabled: true }` and you can add it on security rules.
  - Additionally, you can enable `set enable field on user document` to yes. This will add `disabled` field on user documents and you can search(list) users who are disabled.

- `SYNC_USER_DISABLED_FIELD` option only works with `disable_user` command.

  - When it is set to yes, the `disabled` field with `true` will be set to user document.
  - Use this to know if the user is disabled.

- Request

```ts
{
  command: 'delete_user',
  uid: '--user-uid--',
}
```

<!-- - Warning! Once a user changes his displayName and photoUrl, `EasyChat.instance.updateUser()` must be called to update user information in easychat. -->

# Translation

The text translation for i18n is in `lib/i18n/i18nt.dart`.

By default, it supports English and you can overwrite the texts to whatever language.

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

<!-- Disabling user -->