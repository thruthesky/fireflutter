# Table of Contents 


<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Overview](#overview)
- [Comment Service](#comment-service)
- [Widget](#widget)
  - [Comment Doc](#comment-doc)
  - [CommentEditBottomSheet](#commenteditbottomsheet)
  - [CommentListView](#commentlistview)
  - [CommentListTile](#commentlisttile)
  - [CommentListBottomSheet](#commentlistbottomsheet)
  - [CommentViewScreen](#commentviewscreen)
- [Customization](#customization)
  - [CommentCustomize](#commentcustomize)
- [Comment Sorting](#comment-sorting)

<!-- /code_chunk_output -->


# Comment
## Overview

User comments on posts so in this section will show you how to handle comments from each post. Utilizing every widgets and function calls will help you to create a `Feed Page` for your app. 

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
## Widget
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
showGeneralDialog(
  pageBuilder: (context,_,__) => CommentEditBottomSheet(post: post),
) 
// or use a service
CommentService.instance.showCommentEditBottomSheet(post:post),
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
## Customization

### CommentCustomize

Using this widget you can customize the behaviour of your comment. 

Use `init` from `CommentService` 
```dart
CommentService.instance.init(
  customize: CommentCustomize(
  showCommentListBottomSheet: (context, post) {
    // code here
    } 
  ),
);
```
or you can use the `customize`
```dart
CommentService.instance.customize.showCommentEditBottomSheet = (context){
  // code here
};
```

## Comment Sorting
If you go to Firestore and navigate to `comments/{commentId}/` and look at the `order` You can see the numbers `10000.100010....100000`, this represents the `depths` of each comment from its `parentId`. 

Each dot on `100000.100000.100000.100000.100000.100000.100000.100000.100000.100000` represents a `depth` of a comment adding the total number of comments from a post. So if `depth = 2` and  `totalNoOfComments = 15` the sort will be `100000.100015........100000`

``` dart
 [This is the original Post]

-> {(A) first comment} // depth 1, order: 100000.........100000
  -> {(a) reply on (A) comment} // depth 2, order: 100000.100002........100000 // 
    -> {(b) reply on (a) comment} // depth 3, order: 100000.100002.100003.......100000 // 
      -> {(c) reply on (b) comment} // depth 4, order: 100000.100002.100003.100004......100000 //
```