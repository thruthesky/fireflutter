# Comments

<!-- TODO example comments -->
<!--
    TODO fix mark down lint config for second line bullets
    reference: https://github.com/DavidAnson/vscode-markdownlint#configure
-->

## Comment Model

Fields:

<!-- TODO review description all other fields -->

- DatabaseReference ref;
  - Referance in RTDB to access the comment
- String id;
  - The ID of the category
- final String? parentId;
  - This it when the comment is represented as a reply under an existing comment.
- String content;
  - The main content which is the actual comment.
- final String uid;
  - The commenter's uid.
- final int createdAt;
  - When the comment was created, in milliseconds since epoch
- List of String urls = [];
  - urls of the attached files (mostly for photos)
- int depth;
  - depth of the comment (for indention in replies).

## CommentView Widget

To view a comment, use like below:

<!-- TODO test example -->

```dart

final CommentModel comment = CommentModel.fromMap({
        'uid': uid,
        'createdAt': createdAt,
        'urls': urls,},);
return CommentView(
    post: post,
    comment: comment,
    onCreate: () {
        post.reload().then((value) => setState(() {}));
    },
);
```
