# Forum

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

As you know, we are using realtime database. This means the app should observe for data change as small portiona as it can be. And we made it simple for post data changes. Use `PostModel.onFieldChange(field, callback)`.

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
    final post = await PostModel.get(category: 'discussion', id: '-No5q8HHMw7ZDZSjR-Qu');
    print('length of comment; ${post?.comments.length}');
    for (final c in post?.comments ?? []) {
      print("[${c.depth}] ${c.content}");
    }
  });
});
```

## Comments


Comments are saved under `/comments/<post-id>`.




## Posts

Refer to [Post doc](post.md).
