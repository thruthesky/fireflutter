# Typesense 검색

- 2024. 04. 12. 이후, Typesense 관련 Cloud 함수를 모두 삭제하고, 대신 검색에 필요한 모든 데이터는 Firestore 로 미러링해서 Firestore 및 exstension 으로 해결한다. 즉, 개발자들의 취향에 맞게 직접 커스텀 할 수 있도록 하는 것이다.

- 만약, 어떠한 이유로 사용자 정보가 Typesense 에 색인되지 않았을 수 있다. 이와 같은 경우, 사용자 정보를 수정하면 Typesense 에 색인된다.

## 설치

- Typesense 의 경우 Api Key 를 백엔드와 프론트엔드에 지정해야 한다.
    - 백엔드는 Cloud Functions 의 `firebase/functions/src/config.ts` 이고,
    - 프론트엔드는 플러터에서 `TypesenseService.instnace.init()` 에서 하면 된다.

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
```

**Make sure to create the collection in Typesense.**

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
