# Comments

## Comment Model

Fields:

- DatabaseReference ref;
  * Referance in RTDB to access the comment
- String id;
  * The ID of the category
- String category;
  * Category is not saved in RTDB since it is accessible in post but it is important in the model.
- String postId;
  * Post's Id is not saved in RTDB since it is accessible in post but it is important in the model.
- final String? parentId;
  * This it when the comment is represented as a reply under an existing comment.
- String content;
  * The main content which is the actual comment.
- final String uid;
  * The commenter's uid.
- final int createdAt;
  * When the comment was created, in milliseconds since epoch
- List of String urls = [];
  * urls of the attached files (mostly for photos)
- int depth;
  * depth of the comment (for indention in replies).
- bool deleted
  * Whether the comment is deleted. True means deleted.
  
## CommentView Widget

To view a comment, use like below:

```dart
final CommentModel comment = CommentModel.fromMap({
    'uid': uid,
    'createdAt': createdAt,
    'urls': urls,
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
        onCommentCreate: (CommentModel comment) => toast("Created comment: $comment"),
        onCommentUpdate: (CommentModel comment) => toast("Updated comment: $comment"),
        onCommentDelete: (CommentModel comment) => toast("Deleted comment: $comment"),
    );
}
```
