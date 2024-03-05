# Comments  

A comment is created by users to comment on a post.

Comments are saved under `/comments/<post-id>`.

## CommentView Widget

To view a comment, use like below:

```dart
final Comment comment = Comment.fromMap({
    `uid`: uid,
    `createdAt`: createdAt,
    `urls`: urls,
  },
);

return CommentView(
    post: post,
    comment: comment,
    onCreate: () {
        post.reload().then((value) => setState(() {}));
    },
);
```

## onCommentCreate, onCommentUpdate, onCommentDelete

To add custom code upon creating, updating or deleting the comment, you may set `onCommentCreate`, `onCommentUpdate` and `onCommentDelete` in the `ForumService.instance.init()` at the app start.

The custom codes will be ran after the event.

### Initializing

Check the example code below to understand how to set these onCommentCreate, onCommentUpdate, and onCommentDelete. Put initialize recommendedly on initialization in main.

```dart
initForum() {
    ForumService.instance.init(
        // ... 
        onCommentCreate: (Comment comment) => print("Created comment: $comment"),
        onCommentUpdate: (Comment comment) => print("Updated comment: $comment"),
        onCommentDelete: (Comment comment) => print("Deleted comment: $comment"),
    );
}
```

## Listing comments

Comments will be provided by the Post. For customization, check the code below:

```dart
final post = Post(
  // get the post model
);

return CommentListView(post: post);
```
