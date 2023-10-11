
<!-- This widget may be removed since Widgets section will be added for each markdown file -->
# Table of Contents {ignore = true}


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Widgets](#widgets)
  - [UserDoc](#userdoc)
  - [AuthChanges](#authchanges)
  - [UserDocReady](#userdocready)
  - [TopDownGraident and BottomUpGraident](#topdowngraident-and-bottomupgraident)
  - [CommentOneLineListTile](#commentonelinelisttile)
  - [CommentListBottomSheet](#commentlistbottomsheet)
  - [UserLikedByListScreen](#userlikedbylistscreen)
  - [Functions](#functions)
  - [PostLikeButton](#postlikebutton)
  - [Screen widgets](#screen-widgets)
  - [EmailLoginForm](#emailloginform)
  - [IconTextButton](#icontextbutton)
  - [CarouselView](#carouselview)

<!-- /code_chunk_output -->


# Widgets

## UserDoc
`UserDoc` builds a widget based on the user document changes. This will check the Firestore `/users` or get the `FirebaseAuth.instance.currentUser`.

```dart
return UserDoc(builder: (user) {
    List<String> followers = user.followers.toList();
    List<String> following = user.followings.toList();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          userInfo(user, context),
          const SizedBox(height: sizeLg),
          Text('Viewers: ${following.length}'),
          ProfileViewers(size: size),
          const SizedBox(height: sizeLg),
          Text('Followers: ${followers.length}'),
          ProfileFollowers(size: size, followers: followers),
        ],
      ),
    ),
  }
),
```


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
This will return a `User` object document when it is ready. This will run only once and will not rebuild itself even if user change documents. 
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

The name of widgets that can be used as a screen ends with `Screen`. Those widget must be work as a screen or a dialog of `showGeneralDialog`. Which means those widgets must have a scaffold.

Example of opening a screen widget with `showGeneralDialog`

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