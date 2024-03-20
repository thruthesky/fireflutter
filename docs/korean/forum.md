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

- `category` cannot be changed due to the node structure.

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

## 글 목록


글 목록은 `PostListView`, `PostAllListView`, `PostLatestListView` 등 여러가지가 있다.


### PostListView - 카테고리 별 게시판 목록

카테고리 별 글 목록을 할 때 사용하는 위젯이다. 무한 스크롤을 통해서 글을 보여준다.

```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:silvers/defines/categories.dart';

class PostListScreen extends StatelessWidget {
  static const String routeName = '/PostList';
  const PostListScreen({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Categories.getLabel(context, category)),
        actions: [
          IconButton(
            onPressed: () {
              ForumService.instance
                  .showPostCreateScreen(context, category: category);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: PostListView(
        category: category,
      ),
    );
  }
}
```



### PostAllListView 전체 게시판 목록

카테고리 별로 게시글을 보여주는 것이 아니라, 모든 카테고리의 글을 한번에 무한 스크롤 목록으로 보여주고 싶을 때 사용한다.






### PostLatestListView - 최근 글 목록 가져오기


최근 글을 가져오려면 `PostLatestListView` 를 사용할 수 있으며, 필요에 따라서 소스 코드를 복사하여 적절히 수정해서 사용하면 됩니다.


아래의 예제는 `PostTitle` 위젯을 통해 제목만 출력한다.

```dart
PostLatestListView(
    category: 'qna',
    limit: 5,
    itemBuilder: (post) => PostTitle(post: post)),
```

아래는 `PostListTile` 위젯을 통해 목록에 적당한 UI 로 글 정보를 출력한다.

```dart
PostLatestListView(
    category: 'qna',
    limit: 5,
    itemBuilder: (post) => PostListTile(post: post)),
```


아래의 예제는 하나의 화면에 질문과 답변, 자유게시판의 카테고리들에서 최근글 몇개를 가져와 보여주는 예제이다.

```dart
class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            ...['qna', 'discussion'].map((category) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => context.push(
                      PostListScreen.routeName,
                      extra: {
                        Field.category: category,
                      },
                    ),
                    child: Text(category.toUpperCase()),
                  ),
                  PostLatestListView(
                      category: category,
                      limit: 5,
                      itemBuilder: (post) => PostListTile(post: post)),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
```


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


