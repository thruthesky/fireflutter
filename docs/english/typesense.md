# Typesense

Fireflutter is now managing Typesense thru a cloud function. Refer to [cloud functions document](cloud_functions.md).

TypesenseService must be initialized before using it.

If, for any reason, user information is not indexed in Typesense, updating the user information will trigger the indexing in Typesense.

## Schema

To add Typesense, must have a Typesense Server running. Make sure to include the schema.

```http
@scheme=http
@serverUrl=file.yourdomain.com:9999
@apiKey=yourApiKey123


### Creating the momcafe search collection
POST {{scheme}}://{{serverUrl}}/collections
Content-Type: application/json
X-TYPESENSE-API-KEY: {{apiKey}}

{
   "name": "searchCollection",
   "fields": [
      {"name": "id", "type":"string"},
      {"name": "type", "type": "string"},

      {"name": "uid", "type": "string", "optional": true },
      {"name": "displayName", "type": "string", "optional": true, "infix": true },
      {"name": "photoUrl", "type": "string", "optional": true},
      {"name": "isVerified", "type": "bool", "optional": true},

      {"name": "title", "type": "string", "optional": true},
      {"name": "content", "type": "string", "optional": true},
      {"name": "category", "type": "string", "optional": true},
      {"name": "url", "type": "string", "optional": true},

      {"name": "parentId","type": "string", "optional": true},
      {"name": "postId","type": "string", "optional": true},

      {"name": "createdAt", "type": "int64", "optional": true }
   ]
}

```

## Installation

- For Typesense, you need to specify the API Key for both the backend and frontend.
    - The backend is configured in `firebase/functions/src/config.ts` for Cloud Functions,
    - The frontend configuration is done in Flutter's `TypesenseService.instance.init()`.

## Initialization

Here is an example to initialize the TypesenseService.

```dart
TypesenseService.instance.init(
    apiKey: 'api-pass',
    scheme: 'http',
    host: 'file.phila.com',
    port: 8008,
    searchCollection: 'mySearchCollection',
);
```

**Make sure to create the collection in Typesense.**

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
            final post = Post.fromJson(resDoc.toJson(), id: resDoc.id);
            return PostListTile( post: post );
        }
        if (resDoc.type == TypesenceDocType.comment) {
            final comment = Comment.fromMap(resDoc.toJson(), resDoc.id, category: resDoc.category ?? '', postId: resDoc.postId ?? '');
            return Text("Comment id: ${comment.id}");
        }
        return Text("Error: document is not form user, post, or comment");
    }
);
```
