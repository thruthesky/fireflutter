# Comments  

<!-- TODO revise -->

A comment is created by users to comment on a post.

Comments are saved under `/comments/<post-id>`.

<!-- 
  TODOS
  1. Update Models
  2. Update Cloud Functions (done)
  3. Update Typesense Indexing
  4. Update Refs
-->

## Comment Model

### Fields

- ref
    - DatabaseReference
    - Reference in RTDB to access the comment
- id
    - String
    - The ID of the category
- parentId
    - optional String
    - The ID of the comment`s parent when the comment is represented as a reply under an existing comment.
- content
    - String
    - The main content which is the actual comment.
- uid
    - String
    - The commenter`s uid.
- createdAt
    - int
    - When the comment was created, in milliseconds since epoch
- urls
    - List of Strings
    - default: []
    - urls of the attached files (mostly for photos)
- depth
    - int
    - depth of the comment (for indention in replies).
- deleted
    - bool
    - Whether the comment is deleted. True means deleted. Otherwise, not deleted.

### Getters

- category
    - String
    - The category of the forum where the comment`s post belong.
    - Category is not saved in RTDB since it is accessible in post but it is important in the model.
- postId
    - String
    - The id of the post where the comment is commented.
    - Post`s Id is not saved in RTDB since it is accessible in post but it is important in the model.
  
## CommentView Widget

To view a comment, use like below:

```dart
final CommentModel comment = CommentModel.fromMap({
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
        onCommentCreate: (CommentModel comment) => toast("Created comment: $comment"),
        onCommentUpdate: (CommentModel comment) => toast("Updated comment: $comment"),
        onCommentDelete: (CommentModel comment) => toast("Deleted comment: $comment"),
    );
}
```

## Listing comments

<!-- TODO revise since comments are not in posts -->

Comments will be provided by the PostModel. For customization, check the code below:

```dart
final post = PostModel(
  // get the post model
);

ListView.builder(
  itemCount: post.comments.length,
  itemBuilder: (context, index) {
    final CommentModel comment = post.comments[index];
    return CommentView(
      post: post,
      comment: comment,
      onCreate: () {
        post.reload().then((value) => setState(() {}));
      },
    );
  },
)
```

## Comment create logic

- There followings are the comments fields. There is no `category`, `postId`, `id`.
    - `content`: optional
    - `parentId`: null for root level comment. required for child of root level comment. (required for comment of comment)
    - `uid`: required
    - `createdAt`: required
    - `urls`: optional
