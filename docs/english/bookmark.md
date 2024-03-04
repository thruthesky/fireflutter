# Bookmark

- Bookmarks, are used to save information that users want to revisit later. These are different from `likes`.
- Bookmarks are synonymous with favorites or favorites.
- In Realtime Database, they are stored in the format `/bookmarks/<user_UID>/<Target_UID>`.
- The value can be:
    - If `otherUserUid` is present, it's a user bookmark.
    - If `category` is present, it's a post bookmark.
    - If `commentId` is present, it's a comment bookmark.
    - Chat rooms are not bookmarked.
- The `Bookmark.toggle()` can be used to add or to remove a bookmark.

## Bookmark List

Below is the basic code for bookmarks. If needed, you can copy and modify the BookmarkListView for your use:

```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BookmarkScreen extends StatefulWidget {
  static const String routeName = '/Bookmark';
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: const BookmarkListView(),
    );
  }
}
```
