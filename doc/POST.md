# Post

## Features

- Create Posts

## Model

Post class is the model for posts.
It has:

- id
- categoryId
- title
- content
- uid
  - the uid of the creator of the post
- files
  - the list of file URLs.
- createdAt
- updatedAt
- likes
- deleted

## Widgets

### Post List View

Post List View displays a list for the posts.

To list all posts, simply follow the code:

```dart
PostListView(),
```

In the above example, the list will be all posts regardless of their category.

To filter by category, add the category argument like below:

```dart
Category? category;

// ---

if (widget.categoryId != null && category == null) {
    CategoryService.instance.get(widget.categoryId!).then((value) {
        setState(() {
            category = value;
        });
    });
}

// ---

PostListView(
    category: category,
),
```

The above code will list all the post under the category

### Post Dialog

Post Dialog is a full screen dialog that display the post.

To use the widget, add this to body, to children etc.:

```dart
PostViewScreen(post: post)
```

Take note that the code above needs the Post to display.

## Post Service Usage

### Displaying the create dialog

PostService provies showCreateDialog function that can be used to show a Create Post Form. Below is an example of usage:

<!-- showCreateDialog doesn't exists [??] -->

```dart
IconButton(
    icon: const Icon(Icons.add),
    onPressed: () {
        PostService.instance.showCreateDialog(
        context,
        category: category!,
        success: (val) {
            Navigator.pop(context);
        },
    );
    },
),
```
