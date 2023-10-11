# Table of Contents 


<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Overview](#overview)
- [Comment Service](#comment-service)
  - [CommentListView](#commentlistview)

<!-- /code_chunk_output -->


# Comment
## Overview

## Comment Service
Comment Service provides a widget builder that you can use from retrieve data to display them into your app.

```dart
final service = CommentService.instance;

// Create a comment instantly
service.createComment(post: post, content: content); // returns Future<Comment>

// Display the Edit dialog as bottom sheet
// [post] is where the comment came from
// [parent] is a parent comment where the current comment came from  
service.showCommentEditBottomSheet(context, post: post, parent: parent, comment: comment); // returns Future<Comment?>

// Display all comments from the post in a List View manner as a Bottom Sheet 
service.showCommentListBottomSheet(context,post); 
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

### CommentListView
A List View of Comments on top of FirestoreListView.

```dart
Dialog(
  child: Padding(
    padding: const EdgeInsets.all(sizeSm),
    child: CommentListView(post: post),
  ),
),
```
<!-- 
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
``` -->

<!-- TODO: continue to add widgets here -->