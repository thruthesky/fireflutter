# Typesense

## How to

- Typesense is not tightly coupled with fireship. Meaning, you have to manually code to index.
- TypesenseService must be initialized before using it.

### How to index

- Below is an example of indexing.

```dart
TypesenseService.instance.init(
    apiKey: '12345a',
    scheme: 'http',
    host: 'file.philgo.com',
    port: 8108,
    searchCollection: 'search',
);
UserService.instance.init(
    onCreate: TypesenseService.instance.upsertUser,
    onUpdate: Types
    enseService.instance.upsertUser,
);
ForumService.instance.init(
    onPostCreate: TypesenseService.instance.upsertPost,
    onPostUpdate: TypesenseService.instance.upsertPost,
    onPostDelete: TypesenseService.instance.delete,
    onCommentCreate: TypesenseService.instance.upsertComment,
    onCommentUpdate: TypesenseService.instance.upsertComment,
    onCommentDelete: TypesenseService.instance.delete,
);
```

<!-- 
    TODO
    I think we should give instruction on how to create the collection in Typesense.
-->

### How to search

To search, `TypesenseService.instance.search` can be used. Check the example code below:

```dart
final searchParameters = {
    'q': 'Your Searching Text',
    'query_by': 'user,post,comment',
    'filter_by': 'category:=discussion',
    'page': '1',
    'per_page': '10',
    'sort_by': 'createdAt:desc'
};

final re = await TypesenseService.instance.search(searchParameters: searchParameters);

final itemsResult = re.getDocs;

return ListView.builder(
    itemCount: itemsResult.length,
    itemBuilder: (context, index) {
        final resDoc = itemsResult[index];
        if (resDoc.type == TypesenceDocType.user) {
            final user = UserModel.fromJson(resDoc.toJson());
            return Text("User uid: ${user.uid}");
        }
        if (resDoc.type == TypesenceDocType.post) {
            final post = PostModel.fromJson(resDoc.toJson(), id: resDoc.id);
            return PostListTile( post: post );
        }
        if (resDoc.type == TypesenceDocType.comment) {
            final comment = CommentModel.fromMap(resDoc.toJson(), resDoc.id, category: resDoc.category ?? '', postId: resDoc.postId ?? '');
            return Text("Comment id: ${comment.id}");
        }
        return Text("Error: document is not form user, post, or comment");
    }
);    
```
