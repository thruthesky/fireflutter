## AuthChanges
`AuthChanges` is a builder with listener of Firebase `authStateChanges`. It return `User` and will rebuild itself everytime the user signed in or out.  
```dart
AuthChange(
  builder: (user) => user == null ? // check if user is null then 
    Text('Register') : Text('uid: ${user.uid}'),
);
```
<!-- TODO: Explanation of authchange and userdocready -->
## UserDocReady

```dart
UserDocReady(builder: (my) {
  return Row(
    children: [
      UserProfileAvatar( user: my ),
      Column(
        children: [
          Text(my.name),
          Text("${my.birthYear}-${my.birthMonth}-${my.birthDay}"),
        ],
      ),
    ],
  );
}),
```

## TopDownGraident and BottomUpGraident

`TopDownGraident()` and `BottomUpGraident()` provides
gradient on top and bottom part of the app. You can use this to design your entry screen or the splash screen.

Using them inside of the `Row()` or `Column()` will return an error below

```sh
Another exception was thrown: Incorrect use of ParentDataWidget.
```

You can use this widgets like this

```dart
Stack(
  children: [
    // gradients are always on top so it will be the first to draw
    TopDownGraident(
      height: 150,
    ),
    BottomUpGraident(
      height: 100,
    ),
    // .... your widgets here
  ],
),
```

## CommentOneLineListTile

<!-- TODO:
  - code errors permission_denied is the reason why not working properly,
  - Note: I added the id as an admin
 -->

Below is a sample code how to use and customizing `CommentOneLineListTile` widget.

```dart
Theme(
  data: Theme.of(context).copyWith(
    textTheme: TextTheme(
      bodySmall: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontSize: 12,
            color: Colors.red,
          ),
    ),
  ),
  child: CommentOneLineListTile(
    post: Post.fromJson({'id': '1'}),
    comment: Comment.fromJson({
      'id': '2',
      'postId': '1',
      'uid': '2ItnEzERcwO4DQ9wxLsWEOan9OU2',
      'sort': '...',
      'depth': 1,
      'content': "This is a test content.\nHello, there.\nYo!",
      'urls': ['https://picsum.photos/id/100/100/100', 'https://picsum.photos/id/101/100/100'],
    }),
  ),
),
```

<!-- Fixed -->

## CommentListBottomSheet

This widget shows the comment list of the post in a bottom sheet UI style.
Use this widget with `showModalBottomSheet`.

```dart
Post post = Post(id: 'xxx');
await showModalBottomSheet(
  context: context,
  builder: (ctx) => CommentListBottomSheet(post: post),
);
```

<!-- renamed from UserLikeListScreen to UserLikedByListScreen -->

## UserLikedByListScreen

This screen shows a list of users who liked a post, comment, or a profile.
Use this screen to show a user list and when it is tapped, show public profile.

```dart
UserLikedByListScreen(
    uids: ['xxx''xxx''xxx'], // list of ids
  ),
```
## Functions
See [FUNCTIONS.md](/doc/FUNCTIONS.md) for more details.

## PostLikeButton

Use this widget for like and unlike.

```dart
PostLikeButton(
  padding: const EdgeInsets.all(sizeXs),
  post: post,
  builder: (post) => Icon(post.iLiked ? Icons.thumb_up : Icons.thumb_up_outlined),
),
```

## Screen widgets

The name of widgets that can be used as a screen ends with `Screen`. Those widget must be work as a screen or a dialog of `showGeneralDialog()`. Which means those widgets must have a scaffold.

Example of opening a screen widget with `showGeneralDialog()`

```dart
showGeneralDialog(
  context: context,
  pageBuilder: (_, __, ___) => const AdminDashboardScreen(),
);
```

Example of opening a screen widget with `Navigator`

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (c) => const AdminDashboardScreen()),
);
```

## EmailLoginForm

Use this widget for creating and logging-in with email/password. This widget is designed for test use.

**_EmailLoginForm()_** structure:

```dart
class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({
    super.key,
    this.register = true,
    this.onLogin,
  });

  final bool register;
  final VoidCallback? onLogin;
}
```

You can use `Theme()` to design the widgets. Example below:

```dart
Theme(
  data: ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(200),
                    ),
                ),
              ),
              child: EmailLoginForm(
                // a function that will trigger if login is successful
                onLogin: () => context.push(HomePage.routeName),
                // removes the register button
                register: false,
              ),
            ),
```

## UserDoc

To display user's profile photo, use like below.

<!-- See the comment for the details. -->

```dart
UserDoc(
  builder: (user) => UserProfileAvatar(
    user: user,
    size: 38,
    shadowBlurRadius: 0.0,
    onTap: () => context.push(ProfileScreen.routeName),
    defaultIcon: const FaIcon(FontAwesomeIcons.lightCircleUser, size: 38),
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  ),
),
```

<!--
Not exist anymore:
documentNotExistBuilder: () {
    // Create user document if not exists.
    UserService.instance.create();
    return const SizedBox.shrink();
  },
   -->

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

## IconTextButton

![IconTextImage](https://github.com/thruthesky/fireflutter/blob/main/doc/img/icon_text_button.jpg?raw=true)

```dart
IconTextButton(
  icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: 22),
  iconBackgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(20),
  iconRadius: 20,
  iconPadding: const EdgeInsets.all(12),
  runSpacing: 4,
  label: "SHARE",
  labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
        fontSize: 10,
        color: Theme.of(context).colorScheme.secondary,
      ),
  onTap: () {},
),
```

## CarouselView

This can be used to display multiple pictures (or media as widgets) as a carousel like in other social media postings.

To use, check this example code below

```dart
CarouselView(
  widgets: [
    CachedNetworkImage(
      imageUrl: e1.url,
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(height: 400),
    ),
    CachedNetworkImage(
      imageUrl: e2.url,
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(height: 400),
    ),
    CachedNetworkImage(
      imageUrl: e3.url,
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(height: 400),
    ),
  ],
),
```

You can also use a List of URLs to display in carousel as shown below.

```dart
CarouselView(
  urls: [
    'picsum.photos/id/223/200/300',
    'picsum.photos/id/224/200/300',
    'picsum.photos/id/225/200/300',
  ],
),
```