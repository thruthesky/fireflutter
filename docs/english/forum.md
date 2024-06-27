# Forum

## Forum initialization

Initialize the `ForumService` by calling `ForumService.instance.init()`.

```dart
  void initState() {
    super.initState();
    ForumService.instance.init();
  }
```

ForumService provices before and after hooks for `Post` and `Comment` CRUD.

So the developer can do what ever needed to do before/after updating the database.

`before{EventName}` event happens just before it update the database. 

`on{EventName}` event happend just after the database is updated.

Hooks available for Post.

- beforePostCreate
- beforePostUpdate
- beforePostDelete
- onPostCreate
- onPostUpdate
- onPostDelete

```dart
  void initState() {
    super.initState();
    ForumService.instance.init(
      beforePostCreate: (data, category) async {
        // do something and return the updated data
        return data;
      },
      beforePostUpdate: (data) async {
        // do something and return the updated data
        return data;
      },
      beforePostDelete: (post) async {
        // do something on the post before delete
      },
      onPostCreate: (post) => {
        // do something after post create
      },
      onPostUpdate: (post) => {
        // do something after post updated
      },
      onPostDelete: (post) => {
        // do something after post deleted
      }
    );
  }
```

Hooks available for Comment.

- beforeCommentCreate
- beforeCommentUpdate
- beforeCommentDelete
- onCommentCreate
- onCommentUpdate
- onCommentDelete

```dart
  void initState() {
    super.initState();
    ForumService.instance.init(
      beforeCommentCreate: (data, comment) async {
        // do something and return the updated data
        return data;
      },
      beforeCommentUpdate: (data, comment) async {
        // do something and return the updated data
        return data;
      },
      beforeCommentDelete: (comment) async {
        // do something on the comment before delete
      },
      onCommentCreate: (comment) => {
        // do something after comment create
      },
      onCommentUpdate: (comment) => {
        // do something after comment updated
      },
      onCommentDelete: (comment) => {
        // do something after comment deleted
      }
    );
  }
```

## Database strucuture

- `/post-summary/<category>` is for listing posts in a category list. It will have a summary of the post.
  - It includes `64 letters of title`, `128 letters of content`, `category`, `id`, `uid`, `createdAt`, `order`.
  - it does not include `no of likes`, `no of comments`. It needs to get those information from `/posts`.
  - The client app is reponsible to manage(crud) the summary posts under `/post-summary/<category>`.
- `posts` is for saving all the post data.
- `posts/<category>/<postId>/comments` is for saving the comments for the post.

- `/post-all-summary` is a place(path) that all post summaries are being saved.
  - You can use this data to display all the posts of all categories in the same page.
  - The data under `/post-all-summary` is managed by cloud functions. And you need to install `managePostAllSummary` cloud function to make it work.
  - See install.md to know how to install `managePostAllSummary` function.

## Coding Guideline

- `category` cannot be changed due to the node structure.

## Observing post changes and update data

As you know, we are using realtime database. This means the app should observe for data change as small portiona as it can be. And we made it simple for post data changes. Use `Post.onFieldChange(field, callback)`.

The example below listens the title changes and if it is changed, it wil update on screen.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: post.onFieldChange(Field.title, (v) => Text(v ?? '')),
    )
  );
}
```

## Test code

You can load a post like below and do whatever test.

```dart
SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
  Timer(const Duration(microseconds: 200), () async {
    final post = await Post.get(category: 'discussion', id: '-No5q8HHMw7ZDZSjR-Qu');
    print('length of comment; ${post?.comments.length}');
    for (final c in post?.comments ?? []) {
      print("[${c.depth}] ${c.content}");
    }
  });
});
```

## Comments

Refer to [Comment doc](comments.md).

## Posts

Refer to [Post doc](post.md).

## Post List

```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:silvers/defines/categories.dart';

class PostListScreen extends StatelessWidget {
  static const String routeName = '/PostList';
  const PostListScreen({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Categories.getLabel(context, category)),
        actions: [
          IconButton(
            onPressed: () {
              ForumService.instance
                  .showPostCreateScreen(context, category: category);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: PostListView(
        category: category,
      ),
    );
  }
}
```

## Push Notification Subscription

To subscribe or unsubscribe to push notifications for forum categories, follow the steps below.

```dart
IconButton(
  onPressed: () async {
    toggle(Path.postSubscription(category));
  },
  icon: Value(
    path: Path.postSubscription(category),
    builder: (v) => v == true
        ? const Icon(Icons.notifications_rounded)
        : const Icon(Icons.notifications_outlined),
  ),
),
```
