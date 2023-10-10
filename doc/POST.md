# Post
<!-- vscode-markdown-toc -->
* [Features](#Features)
* [Model](#Model)
* [Widgets](#Widgets)
	* [Post List View](#PostListView)
	* [Post Dialog](#PostDialog)
* [Post Service Usage](#PostServiceUsage)
	* [Displaying the create dialog](#Displayingthecreatedialog)
* [Post Document Strucutre](#PostDocumentStrucutre)
* [Post view screen custom design](#Postviewscreencustomdesign)
* [List of viewer on each post](#Listofvieweroneachpost)
* [Get/Set/Update/Toggle](#GetSetUpdateToggle)
* [Database widget](#Databasewidget)
* [DatabaseCount widget](#DatabaseCountwidget)
* [Photo upload](#Photoupload)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


## Features

- Create Posts

## Model

Post class is the model for posts.
It has:

- id
- categoryId
- title
- content
- uid
  - the uid of the creator of the post
- files
  - the list of file URLs.
- createdAt
- updatedAt
- likes
- deleted

## Widgets

<!-- .customize does not exist[???],

TODO: Learning it more so i can replace it

  might remove since there is already a section of Post Below
-->

<!-- ## PostService

### How to open a post
Call the `showPostViewScreen` to show the full screen dialog that displays the post

```dart
PostService.instance.customize.postViewScreenBuilder = (post) => GRCCustomPostViewScreen(post: post);
```

### Customizing a Post View

Build your own UI design of the full screen Post View like below.

```dart
PostService.instance.customize.postViewScreenBuilder = (post) => GRCCustomPostViewScreen(post: post);
```

The widget is preferrably a full screen widget. It can be a scaffold, sliver, etc. -->

## PostService

If `enableNotificationOnLike` is set to true, then it will send push notification to the author when there is a like. You would do the work by adding `onLike` callback.

```dart
PostService.instance.init(
  onLike: (Post post, bool isLiked) async {
    if (!isLiked) return;
    MessagingService.instance.queue(
      title: post.title,
      body: "${my.name} liked your post.",
      id: myUid,
      uids: [post.uid],
      type: NotificationType.post.name,
    );
  },
  // When it is set to true, you don't have add `onLike` callback to send push notification.
  enableNotificationOnLike: true,
```



Or you can do the UI/UX by yourself since it delivers everything you need to show comment edit box.

### Post List View

Post List View displays a list for the posts.

To list all posts, simply follow the code:

```dart
PostListView(),
```

In the above example, the list will be all posts regardless of their category.

To filter by category, add the category argument like below:

```dart
Category? category;

// ---

if (widget.categoryId != null && category == null) {
    CategoryService.instance.get(widget.categoryId!).then((value) {
        setState(() {
            category = value;
        });
    });
}

// ---

PostListView(
    category: category,
),
```

The above code will list all the post under the category

### Post Dialog

Post Dialog is a full screen dialog that display the post.

To use the widget, add this to body, to children etc.:

```dart
PostViewScreen(post: post)
```

Take note that the code above needs the Post to display.

## Post Service Usage

### Displaying the create dialog

PostService provies showCreateDialog function that can be used to show a Create Post Form. Below is an example of usage:

<!-- showCreateDialog doesn't exists [??] -->

```dart
IconButton(
    icon: const Icon(Icons.add),
    onPressed: () {
        PostService.instance.showCreateDialog(
        context,
        category: category!,
        success: (val) {
            Navigator.pop(context);
        },
    );
    },
),
```
<!-- From README.md -->
## Post Document Strucutre

Posts are saved in `/posts/{postId}`.

- `hashtags` is an array of string that has the hash tags for the post.

## Post view screen custom design

If you want to design the whole screen of post view,

- you can copy the whole code insode `fireflutter/lib/src/widget/post/view/post.view.screen.dart` into a new screen
- and connect it to `PostService.instance.customize.postViewScreen`,
- and you can start to design your own screen.

Example of connecting your own screen to post view.

```dart
Post.create(categoryId: categoryId.text, title: title.text, content: content.text).then(
  (post) {
    context.pop();
    return PostService.instance.showPostViewScreen(context: context, post: post);
  },
);

```

<!-- Outdated [???]
PostService.instance.showPostViewScreen =
    (context, {String? postId, Post? post}) => showGeneralDialog(
          context: context,
          pageBuilder: (context, $, $$) =>
              MomcafePostViewScreen(postId: postId, post: post),
        );
 -->

If you want to customize of a portion of the existing ui, you may use `PostService.instance.customize.postViewXxxx`. For instance, if you want to add a button on the post view screen, simply do the following.

```dart
PostService.instance.customize.postViewButtons = (post) => PostViewButtons(
      post: post,
      middle: [
        TextButton(
          onPressed: () {},
          child: const Text("New Button"),
        ),
      ],
    );
```

You can actullay rebuild the whole buttons by providing new widget instead of the `PostViewButtons`.

## List of viewer on each post

FireFlutter provides a way of display who viewed which posts. It may be used for dsiplaying the viewers of the post or simple display the no of viewers.

The list of viewers is saved uner `/posts/{post_id}/seenBy/{uid}`. If the user who didn't log in views the post, then the user will not be added into the list of view.

Note that, this is disabled by default. To turn it on, `init(enableSeenBy: true)` on service initialization.

Note that, saving the uid is done by `Post.fromDocumentSnapshot`.

# Database

## Get/Set/Update/Toggle

We have a handy function in `functions/database.dart` to `get, set, update, toogle` the node data from/to firebase realtime database.

- `get('path')` gets the node data of the path from database.
- `set('path', data)` sets the data at the node of the path into database.
- `update('path', { data })` updates the node of the path. The value must be a Map.
- `toggle('path')` switches on/off the value of the node. If the node of the [path] does not exist, create it and return true. Or if the node exists, then remove it and return false.

Note that, these functions may arise an exception if the security rules are not proeprty set on the paths. You need to set the security rules by yourself. When you meet an error like `[firebase_database/permission-denied] Client doesn't have permission to access the desired data.`, then check the security rules.

Example of `get()`

```dart
final value = await get('users/15ZXRtt5I2Vr2xo5SJBjAVWaZ0V2');
print('value; $value');
print('value; ${User.fromJson(Map<String, dynamic>.from(value))}');
```

Example of `set()` adn `update()`

```dart
String path = 'tmp/a/b/c';
await set(path, 'hello');
print(await get(path));

await update(path, {'k': 'hello', 'v': 'world'});
print(await get(path));
```

## Database widget

`Database` widget rebuilds the widget when the node is changed. Becareful to use the narrowest path of the node or it would download a lot of data.

```dart
// Displaying a Text value
Database(
  path: 'tmp/a/b/c',
  builder: (value) => Text('value: $value'),
),

// Displaying a Text widget with dynamic text.
Database(
  path: pathBlock(post.uid),
  builder: (value, path) => Text(value == null ? tr.block : tr.unblock),
),

// Displaying a toggle IconButton.
Database(
  path: pathPostLikedBy(post.id),
  builder: (v, p) => IconButton(
    onPressed: () => toggle(p),
    icon: Icon(v != null ? Icons.thumb_up : Icons.thumb_up_outlined),
  ),
),
```

## DatabaseCount widget

With database count widget, you may display no of views like below.

```dart
DatabaseCount(
  path: 'posts/${post.id}/seenBy',
  builder: (n) => n == 0 ? const SizedBox.shrink() : Text("No of views $n"),
),
```

where you would code like below if you don't want use database count widget.

```dart
FutureBuilder(
  future: get('posts/${post.id}/seenBy'),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
    if (snapshot.hasError) return Text('Error: ${snapshot.error}');

    if (snapshot.data is! Map) return const SizedBox.shrink();

    int no = (snapshot.data as Map).keys.length;
    if (no == 0) {
      return const SizedBox.shrink();
    }

    return Text("No of views ${(snapshot.data as Map).keys.length}");
  },
),
```

# Settings

The system settings are saved under `/settings` collection while the user settings are saved under `/users/{uid}/user_settings/{settingId}/...` in Firestore and the security rules are set to the login user.

See [the block chapter](#block) to know how to use(manage) the user settings and how to use `Database` widget with it.

# Report

The Report document is saved under `/reports/{myUid-targetUid}` in Firestore. The `targetUid` is one of the uid of the user, the post, or the comment.

Example of reporting

```dart
ReportService.instance.showReportDialog(
  context: context,
  otherUid: 'AotK6Uil2YaKrqCUJnrStOKwQGl2',
  onExists: (id, type) => toast(title: 'Already reported', message: 'You have reported this $type already.'),
);
```

Example of reporting with button widget

```dart
TextButton(
  onPressed: () {
    ReportService.instance.showReportDialog(
      context: context,
      otherUid: user.uid,
      onExists: (id, type) => toast(
          title: 'Already reported', message: 'You have reported this $type already.'),
    );
  },
  style: TextButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.onSecondary,
  ),
  child: const Text('Report'),
),
```

```json
{
  "uid": "reporter-uid",
  "type": "xxx",
  "reason": "the reason why it is reported",
  "otherUid": "the other user uid",
  "commentId": "comment id",
  "postId": "the post id",
  "createdAt": "time of report"
}
```

The type is one of 'user', 'post', or 'comment'.

# Upload

## Photo upload

You can upload photo like below. It will display a dialog to choose photo from photo gallery or camera.

```dart
final url = await StorageService.instance.upload(context: context);
```

The code below displays a button and do the file upload process.

```dart
IconButton(
  onPressed: () async {
    final url = await StorageService.instance.upload(
      context: context,
      progress: (p) => setState(() => progress = p),
      complete: () => setState(() => progress = null),
    );
    print('url: $url');
    if (url != null && mounted) {
      setState(() {
        urls.add(url);
      });
    }
  },
  icon: const Icon(
    Icons.camera_alt,
    size: 36,
  ),
),
```

It has options like displaying a progressive percentage.

You can choose which media source you want to upload.

```dart
IconButton(
  onPressed: () async {
    final url = await StorageService.instance.upload(
      context: context,
      progress: (p) => setState(() => progress = p),
      complete: () => setState(() => progress = null),
      camera: PostService.instance.uploadFromCamera,
      gallery: PostService.instance.uploadFromGallery,
      file: PostService.instance.uploadFromFile,
    );
    if (url != null && mounted) {
      setState(() {
        urls.add(url);
      });
    }
  },
  icon: const Icon(
    Icons.camera_alt,
    size: 36,
  ),
),
```

# No of view

By saving no of view, you know how many users have seen your profle and who viewed your profile. Not only the profile, but also it can be applied to post and more.

fireflutter saves the no of view on porfile at `/noOfView/profile/{myUid}/{otherUId: true}`. And it saves no of views of profile at `/noOfView/post/{postId}/{userId: true}`.

```dart
set("/noOfView/profile/$myUid/$otherUid", true);
```

# Following and Follower

- When A follows B,
  - B is added into `followings` in A's document.
  - A is added into `followers` in B's document.
  - Get the last 50 posts of B and add A into `followers`.

- When A unfollow B,
  - B is removed from `followings` in A's document.
  - A is removed from `followers` in B's document.
  - Get the all posts of B and remove A from `followers`.

- When listing feeds,
  - Search all posts that has your uid in `followers`.


This does not scale well. But don't do this in Cloud Functions to save the downloading data over network.
If you are concerned about pricing, limit last 6 months on updating the `followers` in posts and limit searching posts  within last 6 months.

# Block

A user can block other users. When the login user A blocks other user B, B's posts, comments, and other content generated by B won't be seen by A.

The list of block is saved under `/settings/{my_uid}/{other_uid}`. It is set and removed by `toogle()` function.

Example of the code to block or unblock a user.

```dart
TextButton(
  onPressed: () async {
    final blocked = await toggle(pathBlock(user.uid));
    toast(
        title: blocked ? 'Blocked' : 'Unblocked',
        message: 'The user has been ${blocked ? 'blocked' : 'unblocked'} by you');
  },
  style: TextButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.onSecondary,
  ),
  child: Database(
    path: pathBlock(user.uid),
    builder: (value) => Text(value == null ? 'Block' : 'Unblock'),
  ),
),
```

# Customization

Fireflow supports the full customization for using its features.

For UI customization, there are two main way of updating the UI.

- You can customize the UI/UX with registration on service customize initialization
- You can also customize the UI/UX with each widget.

For instance, to customize the share button, you can do one of the followings

Customizing on the service

```dart
PostService.instance.init(
  customize: PostCustomize(
    shareButtonBuilder: (post) => ShareButton(post: post),
  ),
);
```

Customizing on the widget

```dart
PostCard(
  post: post,
  shareButtonBuilder: (post) => ShareButton(post: post),
),
```

We can also customize by parts of the PostCart

```dart
PostCard(
  post: post,
  color: Theme.of(context).colorScheme.secondary.withAlpha(20),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  contentBackground: Theme.of(context).colorScheme.secondary.withAlpha(20),
  shareButtonBuilder: (post) => ShareButton(post: post),
  customMiddleContentBuilder: (context, post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sizeSm, 0, sizeSm, sizeXs),
      child: Text('This Content is in the lower of main content, upper of the Actions'),
      ),
    );
  },
),
```

Use these to customize by part:

- shareButtonBuilder
- customContainer
- customHeaderBuilder
- customMainContentBuilder
- customMiddleContentBuilder
- customActionsBuilder
- customFooterBuilder

When you customize the UI/UX with the service initialization, it may not update on realtime when you edit and hot-reload.

<!-- ## Share

One feature that fireflutter does not have is share. There is no limitation how you can build your app. You can simply use Firebase Dynamic Link with share_plus package to share posts or profiles. You may customize the UI and add a share button to post view screen. -->

# Callbacks

FireFlutter provides callback functions to handle on user document create, update, delete. And create and update for the posts and comments.

Below is an example of how to index user name, post title, content and comment into supabase.

```dart
UserService.instance.init(
  onCreate: (User user) async {
    await supabase.from('table').insert({
      'type': 'user',
      'documentId': user.uid,
      'uid': user.uid,
      'name': user.name,
    });
  },
  onUpdate: (User user) async {
    await supabase.from('table').upsert(
      {
        'type': 'user',
        'documentId': user.uid,
        'uid': user.uid,
        'name': user.name,
      },
      onConflict: 'documentId',
    );
  },
  onDelete: (User user) async {
    await supabase.from('table').delete().eq('documentId', user.uid);
  },
);

PostService.instance.init(
  uploadFromFile: false,
  onCreate: (Post post) async {
    await supabase.from('table').insert({
      'type': 'post',
      'documentId': post.id,
      'title': post.title,
      'content': post.content,
      'uid': post.uid,
      'category': post.categoryId,
    });
  },
  onUpdate: (Post post) async {
    await supabase.from('table').upsert(
      {
        'type': 'post',
        'documentId': post.id,
        'title': post.title,
        'content': post.content,
        'uid': post.uid,
        'category': post.categoryId
      },
      onConflict: 'documentId',
    );
  },
);

CommentService.instance.init(
  uploadFromFile: false,
  onCreate: (Comment comment) async {
    await supabase.from('table').insert({
      'type': 'comment',
      'documentId': comment.id,
      'content': comment.content,
      'uid': comment.uid,
    });
  },
  onUpdate: (Comment comment) async {
    await supabase.from('table').upsert(
      {
        'type': 'comment',
        'documentId': comment.id,
        'content': comment.content,
      },
      onConflict: 'documentId',
    );
  },
);
```