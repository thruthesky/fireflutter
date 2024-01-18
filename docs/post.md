# Post

<!-- TODO Widget example, Model explanation -->

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
