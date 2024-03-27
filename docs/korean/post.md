# 글


- 글 목록을 할 때에는 주로 카테고리 별로 목록을 하게 된다.

- 이 때, 카테고리는 따로 DB 에 기록하지 않는다. 즉, 원하는데로 만들어 쓸 수 있다. 예를 들어 `abc` 라는 카테고리를 쓰고 싶다면 그냥 글 작성 할 때, 카테고리를 `abc` 로 저장하고, 글을 보여줄 때 카테고리를 `abc` 로 하면 된다. 이렇게 하면 편리하게 카테고리를 쓸 수 있지만, 카테고리별 설정을 할 수 없게 된다. 예를 들면, 카테고리 관리자 설정이나 부 관리자 설정, 카테고리 별 이름, 설명 등을 기록하지 못해 설정이 어렵다.
  - 권한 문제는 글 CRUD 훅을 통해서 충분히 해결이 가능하고,
  - 카테고리를 따로 DB 에 저장하지 않으므로 발생하는 모든 문제는 충분히 해결 가능하다.




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


#### 글 쓰기 UI 변경

디자인 작업은 하기 나름이다. FireFlutter 에서는 기본적인 디자인만 추가하며 Flutter 의 theme 작업 방식으로 모든 디자인 작업을 변경 할 수 있다.

아래의 예제는 간단히 UI 디자인을 변경하는 기본 예제이다.

```dart
ListTileTheme( // 기존 ListTile 테마를 모두 삭제
  child: PostListView( // 글 목록은 ListView 에 표시하며, ListView 의 옵션 사용 가능.
    category: 'qna',
    padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
    pageSize: 20,
    separatorBuilder: (p0, p1) => Padding( // 각 ListTile 중간에 라인 추가
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 5,
        thickness: 1,
        color: context.outline.withAlpha(64),
      ),
    ),
  ),
),
```

#### 글 목록 그리드뷰로 표시하기

아래의 방식으로 GridView 로 게시글을 표시 할 수 있으며 주로 사진첩(갤러리) 방식으로 사진 위로 리스트를 할 때 사용하면 된다.
참고로 `PostListView.gridView` 는 `GridView.builder` 의 모든 옵션을 다 지원한다.


```dart
PostListView.gridView(
  category: widget.club.id,
  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
  pageSize: 20,
),
```



## 글 쓰기

글 쓰기는 아래와 같이 할 수 있다.

```dart
OutlinedButton(
  onPressed: () => ForumService.instance.showPostCreateScreen(
    context: context,
    category: widget.club.id,
  ),
  child: const Text('글 쓰기'),
),
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

