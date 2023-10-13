# Table of Contents {ignore=true}
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

  - [Overview](#overview)
  - [Post Service](#post-service)
    - [Create Post](#create-post)
    - [Post List View](#post-list-view)
    - [Post as Dialog](#post-as-dialog)
    - [Post Card](#post-card)
  - [Post view screen custom design](#post-view-screen-custom-design)
  - [List of viewer on each post](#list-of-viewer-on-each-post)
  - [Settings](#settings)
  - [Report](#report)
- [Upload](#upload)
  - [Photo upload](#photo-upload)
- [No of view](#no-of-view)
- [Following and Follower](#following-and-follower)
- [Block](#block)
- [Customization](#customization)
- [Callbacks](#callbacks)

<!-- /code_chunk_output -->


# Post {ignore=true}

## Overview
## Post Service

If `enableNotificationOnLike` is set to true, then it will send push notification to the author when there is a like. You would do the work by adding `onLike` callback.

```dart
// When it is set to true, you don't have add `onLike` callback to send push notification.
enableNotificationOnLike: true,
  
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
```

Or you can do the UI/UX by yourself since it delivers everything you need to show comment edit box.

### Create Post

PostService provides showCreateDialog function that can be used to show a Create Post Form. Below is an example of usage:

<!-- showCreateDialog doesn't exists [??] -->

```dart
ButtonRow( // custom buttons
  label: 'Create Post',
  onTap: () {
    // use Post.create() to create Post
    Post.create(categoryId: categoryId.text, title: title.text, content: content.text).then(
      (post) => PostService.instance.showPostViewScreen(context: context, post: post) // open the post after create
    );
  },
)
```

### Post List View

Post List View displays a list of posts regardless of their category.

```dart
Scaffold(
  body: Expanded(
    child: PostListView(),
  )
)
```
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

### Post as Dialog

Post Dialog is a full screen dialog that display the post.

To use the widget, add this to body, to children etc.:

```dart
PostListView(
  itemBuilder: (context, post) => InkWell(
    onTap: () {
      PostService.instance.showPostViewScreen(context: context, post: post);
    },
    child: PostCard(post:post),
  )
```
***Note:*** The code above needs the `Post` to display.

### Post Card
Post Card is a placeholder for each post. It has a default widgets for `comment`,`like`,`favorite` and more that is customizable. 

Use it inside the `PostListView` builder 

```dart
Expanded(
  child: PostListView(
    itemBuilder: (context, post) => InkWell(
      onTap: () {
        PostService.instance.showPostViewScreen(context: context, post: post);
      },
      child: PostCard( // You can use Theme() to style UI
        post: post,
        commentSize: 3,
        shareButtonBuilder: (post) => IconButton(
          onPressed: () {
            ShareService.instance.showBottomSheet();
          },
          icon: const Icon(Icons.share, size: sizeSm),
        ),
      ),
    ),
  ),
),
```

<!-- From README.md -->
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

You can actully rebuild the whole buttons by providing new widget instead of the `PostViewButtons`.

## List of viewer on each post

FireFlutter provides a way of display who viewed which posts. It may be used for dsiplaying the viewers of the post or simple display the no of viewers.

The list of viewers is saved uner `/posts/{post_id}/seenBy/{uid}`. If the user who didn't log in views the post, then the user will not be added into the list of view.

Note that, this is disabled by default. To turn it on, `init(enableSeenBy: true)` on service initialization.

Note that, saving the uid is done by `Post.fromDocumentSnapshot`.

## Settings

The system settings are saved under `/settings` collection while the user settings are saved under `/users/{uid}/user_settings/{settingId}/...` in Firestore and the security rules are set to the login user.

See [the block chapter](#block) to know how to use (manage) the user settings and how to use `Database` widget with it.

## Report

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

We can also customize by parts of the PostCard

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
    },
  );
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