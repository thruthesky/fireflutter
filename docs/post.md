# Post

A post is used for forum that is under a category, that has title, content, comments created by users.

## Post Model

### Fields

- DatabaseReference ref;
    - DatabaseReference
    - Reference in RTDB to access the post
- id
    - String
    - The ID of the category
- title
    - String
    - The title of the post
- content
    - String
    - The actual content of the post
- category
    - String
    - The category where the post belongs.
- uid
    - String
    - The ID of the User who posted it.
- createdAt
    - DateTime
    - When was the post created.
    - In RTDB it is saved as int, milliseconds since epoch.
- order
    - int
    - This is negated createdAt.
    - It is being used to sort the posts since RTDB doesen't have descending order yet.
- likes
    - List of String
    - The uid's of user who liked the post.
- urls;
    - List of String
    - urls of the attached files (mostly for photos)
- comments;
    - List of CommentModel
    - Comments commented under the post.
- noOfLikes
    - int
    - The number of Likers
- noOfComments
    - int
    - The number of comments
    - This is save only under '/posts-summary'. This is not saved under '/posts'.
- deleted
    - bool
    - Whether the comment is deleted. True means deleted. Otherwise, not deleted.

## onPostCreate, onPostUpdate, onPostDelete

To add custom code upon creating, updating or deleting the post, you may set `onPostCreate`, `onPostUpdate` and `onPostDelete` in the `ForumService.instance.init()` at the app start.

The custom codes will be ran after the event.

### Initializing

Check the example code below to understand how to set these onPostCreate, onPostUpdate, and onPostDelete. Put initialize recommendedly on initialization in main.

```dart
initForum() {
    ForumService.instance.init(
        onPostCreate: (PostModel post) => toast("Created post: $post"),
        onPostUpdate: (PostModel post) => toast("Updated post: $post"),
        onPostDelete: (PostModel post) => toast("Deleted post: $post"),
        // ... 
    );
}
```

## Viewing a post

You can use the `ForumService` to View the Post in a screen.

```dart
final post = PostModel(
  // get the post
);

ForumService.instance.showPostViewScreen(
  context,
  post: post,
);
```

It uses Fireship's `PostViewScreen` widget. This is the default screen widget to view post.

For customization, modify the code below.

```dart
final post = PostModel(
  // get the post
);

await showGeneralDialog(
  context: context,
  pageBuilder: ($, $$, $$$) => PostViewScreen(
    post: post,
  ),
);
```

## Posts Listing

The `PostListTile` widget can be used as List Tile. Show a list of posts like the code below.

```dart
FirebaseDatabaseListView(
  query: Ref.postsSummary.child(category).orderByChild(Field.order),
  itemBuilder: (context, snapshot) {
    return PostListTile(
      post: PostModel.fromSnapshot(snapshot),
    );
  },
);
```

Replace the `PostListTile` widget as needed (like customization).

## Post Creation Logic

- Post will be creatd with the following data.
    - uid (required)
    - title (optional)
    - content (optinal)
    - urls (optional)
    - createdAt (required)
    - order (required)

- Right after creation of the post, it will update the post with new `order`. So, if you are working on cloud functions with event trigger, don't be supprised that it may cause multiple write events.
