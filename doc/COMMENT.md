# Comment

## Features

- Create comments under posts

## Model

Comment Class is the model for comments.
It has:

- id
- postId
- content
- uid
  - the uid of the creator of the comment
- files
  - the list of file URLs.
- createdAt
- updatedAt
- likes
- deleted

## Widgets

### CommentListView

A List View of Comments on top of FirestoreListView.

### Comment Box

A form for commenting for a post.

## CommentService

You can customize the `showCommentEditBottomSheet` how to comment edit(create or update) box appears.

The code below simply call `next()` function which does exactly the same as the default logic from `fireflutter`.

```dart
CommentService.instance.init(
  customize: CommentCustomize(
    showCommentEditBottomSheet: (
      BuildContext context, {
      Comment? comment,
      required Future<Comment?> Function() next,
      Comment? parent,
      Post? post,
    }) {
      return next();
    },
  ),
);
```

You may add some custom code like below.

```dart
CommentService.instance.init(
  customize: CommentCustomize(
    showCommentEditBottomSheet: (
      BuildContext context, {
      Comment? comment,
      required Future<Comment?> Function() next,
      Comment? parent,
      Post? post,
    }) {
      if (my.isComplete == false) {
        warning(context, title: '본인 인증', message: '본인 인증을 하셔야 댓글을 쓸 수 있습니다.');
        return Future.value(null);
      }
      return next();
    },
  ),
);
```