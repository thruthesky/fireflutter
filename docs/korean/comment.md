# 코멘트


## 코멘트 데이터베이스 구조

- `/comments/<post-id>/<comment-id>` 에 코멘트가 저장된다. 즉, postId 는 데이터의 parent.id 가 post id 가 된다.
- `parentId` 에는 부모 코멘트의 id 가 저장된다. 만약, 글 바로 아래의 최 상위 댓글이면 `parentId` 필드는 데이터에 존재하지 않는다.
- `category` 에는 부모 글의 카테고리이다.
- `content` 코멘트 내용
- `uid` 코멘트 작성자 uid
- `createdAt` 글 쓴 시간
- `urls` 업로드된 파일(사진) url 배열. 만약 업로드된 url 이 없으면 `urls` 필드는 데이텅 존재하지 않는다.
- `likes` 는 본 코멘트를 좋아요한 사용자의 uid 가 `{ likes: { uid: true } }` 와 같이 저장된다. 좋아요 취소를 하면 해당 uid 가 삭제된다. 즉, false 로 저장하면 안된다.
- `deleted` 는 코멘트가 삭제되면 true 가 된다.

- 그 외 `depth`, `leftMargin`, `ref` 등의 값은 Comment 모델이 모델링을 할 때 생성한다. 즉, DB 에 존재하지 않고, 클라이언트가 만들어서 쓰는 값이다.






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
