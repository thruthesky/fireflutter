# Table of Contents 


<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Overview](#overview)
- [Comment Service](#comment-service)
  - [Comment Doc](#comment-doc)
  - [CommentEditBottomSheet](#commenteditbottomsheet)
  - [CommentListView](#commentlistview)
  - [CommentListTile](#commentlisttile)
  - [CommentListBottomSheet](#commentlistbottomsheet)
  - [CommentViewScreen](#commentviewscreen)
- [Comment Sorting](#comment-sorting)

<!-- /code_chunk_output -->


# Comment
## Overview
<!-- TODO: Overview definition -->

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

### Comment Doc
A builder that will make a widget from the comment's document

```dart
CommentDoc(
  comment: widget.comment,
  builder: (comment) {
    return TextButton(
      child: Text('Like ${comment.noOfLikes}'),
      onPressed: () {
        comment.like();
      },
    );
  },
),
```

### CommentEditBottomSheet
Display a bottom sheet of comments for each post 

```dart
// call it as a widget
onTap: () => showGeneralDialog(
  pageBuilder: (context,_,__) => CommentEditBottomSheet(post: post),
) 
// or use a service
onTap: () => CommentService.instance.showCommentEditBottomSheet(post:post),
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

### CommentListTile
This widget uses ListTile as its parent displaying user information and the comment from the post. It uses by CommentListView.

```dart
CommentListView(
  post:post,
  itemBuilder: (context, comment) => 
    CommentListTile(
      comment: comment, 
      post: post,
    ),
),
```

### CommentListBottomSheet
Using this you can display all comments from the post as bottom sheet.

```dart
showGeneralDialog(
  context: context.
  pageBuilder: (context, _,__,) => 
  CommentListBottomSheet(post: post);
)
```

### CommentViewScreen
Display comments as a new screen. This will open a new `Scaffold` when used.
```dart
onTap: (){
  Navigator.push(
    context, 
    MaterialPageRoute(builder: (context) => 
      CommentViewScreen(comment: comment)
    ),
  );
}

```

## Comment Sorting
When you go to Firestore and navigate to `comments/{commentId}/` and look at the `order` and you can see the numbers `10000.100010....100000`. This represents the `depths` of each comment from its `parentId`. FireFlutter use this to sort the comments and can be easily displayed on Flutter.

``` dart
-> {parent comment} // depth 1, order: 100000.100000.100000.
  -> {}
```