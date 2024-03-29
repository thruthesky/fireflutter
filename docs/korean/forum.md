# 게시판

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


- `category` 는 rtdb 내에 미리 정해져 있거나 관리자 모드에서 따로 카테고리를 생성하는 것이 아니다. 그냥 카테고리 문자열을 적절히 (임의로) 지정해서 쓰면 된다. 예를 들어, `abc` 라는 카테고리가 없는데, 그냥 글 쓰기 할 때, 카테고리 `abc` 라고 쓰고, 글 목록을 할 때, 카테고리를 `abc` 로 해서 목록하면 된다.

- `category` 카테고리 값은 변경 할 수 없다. 이것은 rtdb 의 경로 구조와 문제가 있는데, `/posts` 경로 뿐만아니라 `/post-summary`, `post-all-summary` 등 여러 경로가 복잡하게 얽혀 있어서 그렇다.





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

## 푸시 알림 구독

게시판 카테고리 별 푸시 알림 구독과 해제는 아래와 같이 하면 된다.

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


