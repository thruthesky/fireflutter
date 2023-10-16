
# Table of Contents  


<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Overview](#overview)
- [UserService](#userservice)
- [Like](#like)
- [Favorite/Bookmark](#favoritebookmark)
  - [How to display icon](#how-to-display-icon)
- [Follow and Unfollow](#follow-and-unfollow)
  - [Display Followers](#display-followers)
- [No of profile view](#no-of-profile-view)
- [User profile screen customization](#user-profile-screen-customization)
- [User public screen customization](#user-public-screen-customization)
- [Avatar](#avatar)
- [UserAvatar](#useravatar)
- [UserProfileAvatar](#userprofileavatar)
- [User List View](#user-list-view)
  - [UserListView.builder](#userlistviewbuilder)
- [When user is not logged in](#when-user-is-not-logged-in)

<!-- /code_chunk_output -->


# User

## Overview

`idVerifiedCode` is the code of user's authentication id code. This is used to save user's id code when the user uploaded his id card like passport and the AI (Firebase AI Extension) detect user's information and the verification succeed, the file path is being save in `idVerificationCode`. You may use it on your own purpose.

`complete` is a boolean field to indicate that the user completed updating his profile information.

`verified` is a boolean field to indicate that the user's identification has fully verified by the system. Note that, this is not secured by the rules as of now. Meaning, user can edit it by himself.

`birthDayOfYear` is the birth day of the year. It is automatically set by the `User.update()`. For instance, if the user saves his birth day, then the app should use this kind of code; `my.update(birthYear: 1999, birthMonth: 9, birthDay: 9);` and it will automtically update the `birthDayOfYear` value.

## UserService
`UserService.instance.nullableUser` is _null_ when

- on app boot
- the user don't have documents
- when user has document but `UserService` has not read the user document yet.

`UserService.instance.nullableUser.exists` is _null_ if the user has logged in but no document.

The `UserService.instance.user` or `UserService.instance.documentChanges` may be null when the user document is being loaded on app boot. So, the better way to get the user's document for sure is to use `UserService.instance.get`

Right way of getting a user document.

```dart
UserService.instance.get(myUid!).then((user) => ...);
```

***Note:*** You cannot use `my` until the UserService is initialized and `UserService.instance.user` is available. Or you will see `null check operator used on a null value.` You can use `MyDoc` from [WIDGETS.md](/doc/WIDGETS.md) instead.

## Like

The `likes` data saved under `/likes` in RTDB. Not that, the `likes` for posts and comments are saved inside the documents of the posts and the comments.

See the following example how to display the no of likes of a user and how to increase or decrease the number of the `like`.

Example of text button with like

```dart
TextButton(
  onPressed: () => like(user.uid),
  child: Database(
    path: 'likes/${user.uid}',
    builder: (value) => return Text(value == null ? 'Like' : '${(value as Map).length} Likes'),
  )
),
```

Example of icon button with like

```dart
IconButton(
  onPressed: () => like(user.uid),
  icon: Database(
    path: 'likes/${user.uid}',
    builder: (value) => Icon(
      Icons.favorite_border,
      color: value == null ? null : Theme.of(context).colorScheme.tertiary,
    ),
  ),
),
```
## Favorite/Bookmark

Bookmark is known to be `Favorite`.

- When A bookmarks on B's profile,

  - `/favorites/A/{type: profile, uid: my_uid, otherUid: ..., createdAt: ..., }` will be saved.

- When A bookmarks a post

  - `/favorites/A/{type: post, uid: my_uid, postId: ..., createdAt: ..., }` will be created.

- When A bookmarks a comment,
  - `/favorites/A/{type: comment, uid: my_uid, commentId: ..., created: ... }` will be created.

When A wants to see the bookmarks, the app should display a screen to list the bookmarks by all, type, user, etc.

### How to display icon

Use `FavoriteButton` to display the icon.

```dart
FavoriteButton(
  otherUid: 'abc',
  builder: (re) => FaIcon(re ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heartCirclePlus, size: 38),
),
```

You can use the `Text` widget as child instead of an icon widget.

```dart
FavoriteButton(
  otherUid: user.uid,
  builder: (re) => Text(re ? 'Unfavorite' : 'Favorite'),
  onChanged: (re) => toast(
    title: re ? 'Favorite' : 'Unfavorite',
    message: re ? 'You have favorited this user.' : 'You have unfavorited this user.',
  ),
),
```

You can do an extra action on status changes.

```dart
FavoriteButton(
  otherUid: 'abc',
  builder: (re) => Text(re ? 'Favorite' : 'Unfavorite'),
  onChanged: (re) => toast(
    title: re ? 'Favorited' : 'Unfavorited',
    message: re ? 'You have favorited.' : 'You have unfavorited.',
  ),
),
```

## Follow and Unfollow

This method will make follow or unfollow the user of the [otherUid].

- If the login user is already following [otherUid] then, it will unfollow.
- If the login user is not following [otherUid] then, it will follow.

When it follows or unfollows,

- It will add or remove the [otherUid] in the login user's followings array.
- It will add or remove the login user's uid in the [otherUid]'s followers array.

Note that you may use it with or without the feed service. See the `Feed Service` for the details on how to follow to see the posts of the users that you are following. But you can use it without the feed system.

### Display Followers

To display users followers you can use these following builders:

- `UserService.instance.showFollowersScreen()` will open a new dialog to display the user's follower. Example:

```dart
// custom button
buttonBuilder('Followers',
  onTap: () {
  UserService.instance.showFollowersScreen(
    context: context,
      user: my,
      // [Optional]
      // use itemBuilder to customize
      itemBuilder: (user) => Scaffold(
        body: ListTile(
          leading: UserAvatar(user: user),
          title: Text(user.displayName),
        ),
    ),
  );
}),
```

- `UserListView.builder()` To use this you must have a collection or list of uids of the user's followers then follow the example below:

```dart
List<String> followers = my.followers.toList(); // list of current user's followers

SizedBox( // setting a constraints
  height: size.height / 6,
  child: followers.isEmpty
      ? const Text('No Followers') // display when no followers
      : UserListView.builder(
          uids: followers,
          // customize your widgets
          itemBuilder: (user) => ListTile(
            leading: UserAvatar(user: user),
            title: Text(user!.name),
            trailing: const FaIcon(FontAwesomeIcons.ban),
          ),
        ),
);
```

<!-- TODO: Modify followers from code and display it here
 -->

## No of profile view

A user can see other user's profile. FireFlutter provides a way of count the no of users who saw my profile. It is turned off by default and you can turn it on with `UserService.instance.init(enableNoOfProfileView)`. The history is saved under `/no_of_profile_view_history` collection so you can list and sort.

```json
{
  "uid": "uid_of_profile",
  "seenBy": "uid_of_viewer",
  "type": "user_type of viewer",
  "lastViewdAt": "...",
  "year": "year of view",
  "month": "month of view",
  "day": "day of view"
}
```

The type is the viewer's type. So, the app can display users by type who viewed my profile.
Note that, the year, month, day is the time of the client app. This may be incorrect. The year, month, day is the date information of last view. So, they changes on every view.

## User profile screen customization

You can hide some of the buttons on public profile and add your own buttons like share button.

```dart
UserService.instance.customize.publicScreenBlockButton = (context, user) => const SizedBox.shrink();
UserService.instance.customize.publicScreenReportButton = (context, user) => const SizedBox.shrink();

UserService.instance.customize.publicScreenTrailingButtons = (context, user) => [
      TextButton(
        onPressed: () async {
          final link = await ShareService.instance.dynamicLink(
              type: 'user',
              id: user.uid,
              title: "${user.name}님의 프로필을 보시려면 클릭해주세요.",
              description: "필리핀 생활에 든든한 힘이 되는 대한민국 여성의 파워 맘카페!",
              imageUrl: user.photoUrl);
          Share.share(link, subject: "${user.name}님의 프로필");
        },
        child: Text(
          "공유",
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        ),
      ),
    ];
```

You can add top header buttons like below.

```dart
UserService.instance.customize.publicScreenActions = (context, user) => [
          FavoriteButton(
            otherUid: user.uid,
            builder: (re) => FaIcon(
              re ? FontAwesomeIcons.circleStar : FontAwesomeIcons.lightCircleStar,
              color: re ? Colors.yellow : null,
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'report',
                child: Text(tr.report),
              ),
              PopupMenuItem(
                value: 'block',
                child: Database(
                  path: pathBlock(user.uid),
                  builder: (value, path) => Text(value == null ? tr.block : tr.unblock),
                ),
              ),
            ],
            icon: const FaIcon(FontAwesomeIcons.circleEllipsis),
            onSelected: (value) async {
              switch (value) {
                case 'report':
                  ReportService.instance.showReportDialog(
                    context: context,
                    otherUid: user.uid,
                    onExists: (id, type) => toast(
                      title: tr.alreadyReportedTitle,
                      message: tr.alreadyReportedMessage.replaceAll('#type', type),
                    ),
                  );
                  break;
                case 'block':
                  final blocked = await toggle(pathBlock(user.uid));
                  toast(
                    title: blocked ? tr.block : tr.unblock,
                    message: blocked ? tr.blockMessage : tr.unblockMessage,
                  );

                  break;
              }
            },
          ),
        ];
```

## User public screen customization

To customize the user public profile screen, you can override the showPublicProfileScreen function.

```dart
UserService.instance.customize.showPublicProfileScreen =
    (BuildContext context, {String? uid, User? user}) => showGeneralDialog<dynamic>(
          context: context,
          pageBuilder: ($, _, __) => MomcafePublicProfileScreen(
            uid: uid,
            user: user,
          ),
        );
```

You may partly want to customize the public profile screen instead of rewriting the whole code.

You may hide or add buttons like below.

```dart

    // Public profile custom design

    // Add menu(s) on top of public screen
    UserService.instance.customize.publicScreenActions = (context, user) => [
          FavoriteButton(
            otherUid: user.uid,
            builder: (re) => FaIcon(
              re
                  ? FontAwesomeIcons.circleStar
                  : FontAwesomeIcons.lightCircleStar,
              color: re ? Colors.yellow : null,
            ),
            onChanged: (re) => toast(
              title: re ? tr.favorite : tr.unfavorite,
              message: re ? tr.favoriteMessage : tr.unfavoriteMessage,
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'report',
                child: Text(tr.report),
              ),
              PopupMenuItem(
                value: 'block',
                child: Database(
                  path: pathBlock(user.uid),
                  builder: (value) =>
                      Text(value == null ? tr.block : tr.unblock),
                ),
              ),
            ],
            icon: const FaIcon(FontAwesomeIcons.circleEllipsis),
            onSelected: (value) {
              switch (value) {
                case 'report':
                  ReportService.instance.showReportDialog(
                    context: context,
                    otherUid: user.uid,
                    onExists: (id, type) => toast(
                      title: tr.alreadyReportedTitle,
                      message:
                          tr.alreadyReportedMessage.replaceAll('#type', type),
                    ),
                  );
                  break;
                case 'block':
                  toggle(pathBlock(user.uid));
                  toast(
                    title: tr.block,
                    message: tr.blockMessage,
                  );
                  break;
              }
            },
          ),
        ];

    /// Hide some buttons on bottom.
    UserService.instance.customize.publicScreenBlockButton =
        (context, user) => const SizedBox.shrink();
    UserService.instance.customize.publicScreenReportButton =
        (context, user) => const SizedBox.shrink();
```

## Avatar

This is a similiar widget of the `CircleAvatar` in Material UI.

```dart
Avatar(url: 'https://picsum.photos/200/300'),
```

## UserAvatar

To display user's profile photo, use `UserAvatar`.
Not that, `UserAvatar` does not update the user photo in realtime. So, you may need to give a key when you want it to dsiplay new photo url.

```dart
UserAvatar(
  user: user,
  size: 120,
),
```

## UserProfileAvatar

To let user update or delete the profile photo, use like below.

```dart
UserProfileAvatar(
  user: user,
  size: 120,
  upload: true,
  delete: true,
),
```

To customize the look of `UserProfileAvartar`.

```dart
UserProfileAvatar(
  user: my,
  size: 128,
  radius: 16, // radius
  upload: true,
  uploadIcon: const Padding( // upload icon
    padding: EdgeInsets.all(8.0),
    child: FaIcon(
      FontAwesomeIcons.thinPenCircle,
      size: 32,
      color: Colors.white,
    ),
  ),
),
```

## User List View

Use this widget to list users. By default, it will list all users. This widget can also
be used to search users by filtering a field with a string value.

This widget is a list view that has a `ListTile` in each item. So, it supports the properties of `ListView` and `ListTile` at the same time.

```dart
UserListView(
  searchText: 'nameValue',
  field: 'name',
),
```

Example of complete code for displaying the `UserListView` in a dialog with search box

```dart
onPressed() async {
  final user = await showGeneralDialog<User>(
    context: context,
    pageBuilder: (context, _, __) {
      TextEditingController search = TextEditingController();
      return StatefulBuilder(builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Find friends'),
          ),
          body: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: search,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search',
                  ),
                  onSubmitted: (value) => setState(() => search.text = value),
                ),
                Expanded(
                  child: UserListView(
                    key: ValueKey(search.text),
                    searchText: search.text,
                    field: 'name',
                    avatarBuilder: (user) => const Text('Photo'),
                    titleBuilder: (user) => Text(user?.uid ?? ''),
                    subtitleBuilder: (user) => Text(user?.phoneNumber ?? ''),
                    trailingBuilder: (user) => const Icon(Icons.add),
                    onTap: (user) => context.pop(user),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
```

### UserListView.builder

You may use the `UserListView.builder` if you already have the `List<String>` of uids

```dart
List<String> friends = ['uid1', 'uid2']

UserListView.builder(uids: friends)

```

In using `UserListView.builder`, must check the user if exists to prevent error like the following code:

```dart
UserListView.builder(
  uids: user.followers,
  itemBuilder: (user) {
    // The uid of a User will be null if it doesn't exist in the database.
    // This can happen if the user has been deleted completely in database.
    // This should never happen.
    if (!(user?.exists ?? false)) return const SizedBox();
    return ListTile(
      contentPadding: const EdgeInsets.only(left: sm, right: 0),
      leading: UserAvatar(
        user: user,
        size: 50,
        radius: 30,
      ),
      ...
    );
  },
),

```

## When user is not logged in

This is one way of how to dsplay widgets safely for not logged in users.

```dart
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    // ...
  });


  @override
  Widget build(BuildContext context) {
    // If the user has not logged in yet, display an icon with a warning toast.
    if (notLoggedIn) {
      return IconButton(
        onPressed: () async {
          toast(
              title: tr.user.loginFirstTitle,
              message: tr.user.loginFirstMessage);
        },
        icon: builder(false),
      );
    }
    return StreamBuilder(
      stream: ....snapshots(),
      builder: (context, snapshot) {
        return IconButton(
          onPressed: () async {
            final re = await Favorite.toggle(
                postId: postId, otherUid: otherUid, commentId: commentId);
            onChanged?.call(re);
          },
          icon: builder(snapshot.data?.size == 1),
        );
      },
    );
  }
}

```
<!-- ADDITIONAL: 
  - LoginFirst
 -->