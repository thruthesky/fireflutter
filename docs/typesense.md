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